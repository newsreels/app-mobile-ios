//
//  URLRequest+Extension.swift
//  NewsReels
//
//  Created by Yeshua Lagac on 6/13/21.
//

import Foundation
import CoreServices

extension URLRequest {

    init(service: ServiceProtocol) {
        let urlComponents = URLComponents(service: service)
        self.init(url: urlComponents.url!)
        httpMethod = service.method.rawValue
        service.headers.forEach { key, value in
            addValue(value, forHTTPHeaderField: key)
        }

        // This particular is for custom service
        if let customHeaders = service.customHeaders {
            customHeaders.forEach { key, value in
                addValue(value, forHTTPHeaderField: key)
            }
        }
        
        if service.parametersEncoding == .multipart,
                  case let .requestParameters(parameters) = service.task,
                  let multiPartParams = parameters as? [String: MultipartInput] {
            let boundary = UUID().uuidString
            setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            var contentLength = 0
            var httpBodyData = Data()
            
            httpBodyData.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            multiPartParams.forEach { (key, multipartInput) in
                httpBodyData.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
                if case let .value(value) = multipartInput {
                    if let values = value as? [Any] {
                        values.forEach { one in
                            httpBodyData.appendValue(key: key, value: one)
                            httpBodyData.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
                        }
                    } else {
                        httpBodyData.appendValue(key: key, value: value)
                    }
                } else {
                    var fileName: String? = nil
                    var data: Data? = nil
                    var multipartKey: String? = nil
                    
                    if case let .fileURL(fileURL) = multipartInput {
                        guard let fileData = try? Data(contentsOf: fileURL)
                        else {
                            print("Error || Invalid file data")
                            return
                        }
                        
                        fileName = fileURL.lastPathComponent
                        data = fileData
                        multipartKey = key
                        contentLength += fileData.count
                    } else if case let .data(fileData, fileName: inputFileName) = multipartInput {
                        fileName = inputFileName
                        data = fileData
                        multipartKey = key
                        contentLength += fileData.count
                    }
                    
                    if let fileName = fileName,
                       let data = data,
                       let multipartKey = multipartKey {
                        
                        httpBodyData.appendFileData(key: multipartKey, value: data, fileName: fileName)
                    } else {
                        print("ERROR || Multipart request requirements not met")
                    }
                }
            }
            
            httpBodyData.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
            httpBody = httpBodyData
            
            setValue(String(contentLength), forHTTPHeaderField: "Content-Length")
        } else if service.parametersEncoding == .json,
                  case let .requestParameters(parameters) = service.task {
            guard service.method != .get
            else {
                print("❌ ERROR ❌ || Blocked JSON request body. The service's method is `GET`. GET methods shouldn't have json bodies")
                return
            }
            var jsonObject: Any = parameters
            if let arrayOfDict = parameters[AppParameters.serviceArrayOfParamsKey] {
                jsonObject = arrayOfDict
            }
            httpBody = try? JSONSerialization.data(withJSONObject: jsonObject)
            print("📦 Request parameters || \(service.path) \n \(jsonObject)")
        }
    }
    
    fileprivate static func mimeType(for path: String) -> String {
        let pathExtension = URL(fileURLWithPath: path).pathExtension as NSString
        guard
            let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension, nil)?.takeRetainedValue(),
            let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue()
        else {
            return "application/octet-stream"
        }
        
        return mimetype as String
    }
}

extension Data {
    fileprivate mutating func appendFileData(key: String, value data: Data, fileName: String) {
        self.append("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        let mimetype = URLRequest.mimeType(for: fileName)
        self.append("Content-Type: \(mimetype)\r\n\r\n".data(using: .utf8)!)
        self.append(data)
    }
    
    fileprivate mutating func appendValue(key: String, value: Any) {
        append("Content-Disposition: form-data; name=\"\(key)\"\r\n".data(using: .utf8)!)
        append("\r\n".data(using: .utf8)!)
        append("\(value)".data(using: .utf8)!)
    }
}
