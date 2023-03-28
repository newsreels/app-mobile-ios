//
//  URLSessionProvider.swift
//  NewsReels
//
//  Created by Yeshua Lagac on 6/13/21.
//

import Foundation

final class URLSessionProvider {
    static var shared = URLSessionProvider()
    
    private var session: URLSession
    
    static var jsonDecoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let standardDateFormatter = DateFormatter()
        standardDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        let fullDateFormatter = DateFormatter()
        fullDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        jsonDecoder.dateDecodingStrategy = .custom({ decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            var date: Date? = nil
            if let _date = standardDateFormatter.date(from: dateString) {
                date = _date
            } else if let _date = fullDateFormatter.date(from: dateString) {
                date = _date
            }
            
            guard let date = date else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
            }
            return date
        })
        return jsonDecoder
    }()

    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    /// NOTE: Works only on ServerResponse encapsulated Data
    func request<T: Decodable>(_ type: CleanArray<T>.Type, service: ServiceProtocol, paginationControl: PaginationControl<[T]>? = nil, jsonDecoder: JSONDecoder = URLSessionProvider.jsonDecoder, completion: @escaping (Result<[T], APIServiceError>) -> ()) {
        
        assert(service.usesContainer, "ERROR || Cannot make request on \(service). Using of CleanArray works only when UsesContainer is TRUE")
        
        self.performTask(on: service) { [weak self] data, response, error in
            guard let self = self else { return }
            self.handleDataResponse(
                data: data,
                usingContainer: service.usesContainer,
                pagination: paginationControl,
                response: response,
                error: error,
                completion: completion,
                customDecoder: { [weak self] data in
                    let decoded = try jsonDecoder.decode(ServerResponse<[Throwable<T>]>.self, from: data)
                    let newResponse = ServerResponse<[T]>(
                        pageInfo: decoded.pageInfo,
                        data:  decoded.data?.compactMap{ try? $0.result.get() },
                        errors: decoded.errors,
                        errorStrings: decoded.errorStrings)
                    return newResponse
                })
        }
    }
    
    /// Use if you don't care about the API return
    func request(service: ServiceProtocol, completion: @escaping (Result<EmptyObject, APIServiceError>) -> ()) {
        request(EmptyObject.self, service: service, completion: completion)
    }
    
    func request<T>(_ type: T.Type, service: ServiceProtocol, paginationControl: PaginationControl<T>? = nil, jsonDecoder: JSONDecoder = URLSessionProvider.jsonDecoder, completion: @escaping (Result<T, APIServiceError>) -> ()) where T: Decodable {
        self.performTask(on: service) { [weak self] data, response, error in
            self?.handleDataResponse(data: data, usingContainer: service.usesContainer, pagination: paginationControl, response: response, error: error, jsonDecoder: jsonDecoder, completion: completion)
        }
    }
    
    private func performTask(on service: ServiceProtocol, completion: @escaping (Data?, HTTPURLResponse?, Error?)->()) {
        let request = URLRequest(service: service)
        prettyPrint(.request(request), service: service)
        let networkOperation = NetworkOperation(session: session, request: request) { [weak self] data, response, error in
            self?.prettyPrint(.response(response, data), service: service)
            completion(data, response, error)
        }
        NetworkOperationQueue.shared.addOperation(networkOperation)
    }
    
    private func handleDataResponse<T: Decodable> (data: Data?, usingContainer: Bool, pagination: PaginationControl<T>?, response: HTTPURLResponse?, error: Error?, jsonDecoder: JSONDecoder = URLSessionProvider.jsonDecoder, completion: (Result<T, APIServiceError>) -> (), customDecoder:  ((Data) throws -> ServerResponse<T>)? = nil) {
        guard let response = response else { return completion(.failure(.noResponse)) }
        guard let data = data else { return completion(.failure(.noData)) }
        
        
        switch response.statusCode {
        case 200...299:
            do {
                if T.self == EmptyObject.self {
                    completion(.success(EmptyObject() as! T))
                    return
                }
                if usingContainer {
                    if let errorModel = try? jsonDecoder.decode(ServerResponseError.self, from: data) {
                        if let errors = errorModel.errors {
                            completion(.failure(.apiReturnErrorsList(errors, response.statusCode)))
                            return
                        } else if let errorStrings = errorModel.errorStrings {
                            completion(.failure(.apiReturnErrorsStringList(errorStrings, response.statusCode)))
                            return
                        }
                    }
                    var model: ServerResponse<T>
                    if let customDecoder = customDecoder {
                        model = try customDecoder(data)
                    } else {
                        model = try jsonDecoder.decode(ServerResponse<T>.self, from: data)
                    }
                    guard let responseData = model.data
                    else { return completion(.failure(.noDataInContainer)) }
                    
                    pagination?.nextPageLink = model.pageInfo?.nextLink
                    completion(.success(responseData))
                } else {
                    // Work around for image strings
                    if T.self == ImageData.self {
                        completion(.success(ImageData(data: data) as! T))
                        return
                    }
                    
                    let model = try jsonDecoder.decode(T.self, from: data)
                    completion(.success(model))
                }
            } catch (let error) {
                print("Error || Decode failed: \(error)")
                completion(.failure(.decodeError(error)))
            }
        default:
            // .. add errors here,
            // TODO: Handle errors with array string
            if usingContainer {
                do {
                    let model = try JSONDecoder().decode(ServerResponseError.self, from: data)
                    if let errorStrings = model.errorStrings {
                        completion(.failure(.apiReturnErrorsStringList(errorStrings, response.statusCode)))
                    } else if let errorArray = model.errors {
                        completion(.failure(.apiReturnErrorsList(errorArray, response.statusCode)))
                    } else if let oldError = model.nonFieldErrors {
                        completion(.failure(.apiReturnErrorsStringList(oldError, response.statusCode)))
                    } else {
                        completion(.failure(.apiError(response.statusCode)))
                    }
                } catch let error {
                    return completion(.failure(.decodeError(error)))
                }
            } else if let error = error {
                completion(.failure(.requestError(error: error)))
            } else {
                completion(.failure(.unsupportedDataError))
            }
        }
    }
}

extension URLSessionProvider {
    private enum URLEvent {
        case request(URLRequest), response(URLResponse?, Data?)
    }
    
    private func prettyPrint(_ event: URLEvent, service: ServiceProtocol) {
        if let custom = service as? CustomService,
           !custom.showLogs {
            return
        }
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .long)
        if case .request(let request) = event {
            print("[📤 \(timestamp)] \(request.url?.absoluteString ?? "URL ❌")")
            
            if let header = request.allHTTPHeaderFields {
                print("🗒 Header: ", header.debugDescription)
            }
            
            if let body = request.httpBody,
               let str = String(data: body, encoding: .utf8)  {
                print(str)
            }
        } else if case .response(let response, let data) = event {
            guard let urlResponse = response as? HTTPURLResponse
            else { return print("Error || Invalid response") }
            
            let statusCode = urlResponse.statusCode
            let statusString = "\(statusCode) \(200...299 ~= statusCode ? "": "❌")"
            
            print("[📥 \(timestamp)]  [SERVICE: \(service)] \(urlResponse.url?.absoluteString ?? "URL ❌") \(statusString)")
            
            if let data = data,
               let stringData = String(data: data, encoding: .utf8) {
                print(stringData)
            }
        }
    }
}
