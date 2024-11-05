
import Foundation

typealias result<T> = (Result<T, APIServiceError>) -> Void
typealias response<T> = Result<T, APIServiceError>

struct EmptyObject: Decodable { }
struct ErrorDetailResponse: Decodable { let detail: String }
struct ErrorMessageResponse: Decodable { let message: String }

struct ResponseResponse: Decodable { let response: String }

struct ErrorsResponse: Decodable {
    let key: String
    let value: String
}

struct PageInfo: Decodable {
    let nextLink: String?
    let previousLink: String?
    
    enum CodingKeys: String, CodingKey {
        case nextLink = "next", previousLink = "previous"
    }
}

/**
 A marker struct intended to replace regular Array Types (eg: [SomeDecodable].self) inside URLSessionProvider.request
*/
struct CleanArray<T: Decodable> { }

struct ServerResponse<Element: Decodable>: Decodable {
    
    let pageInfo: PageInfo?
    let data: Element?
    var errors: [ErrorsResponse]? = []
    var errorStrings: [String]? = []
    
    var errorsList: String {return getErrorDescription()}
    
    enum CodingKeys: String, CodingKey {
        case pageInfo, data, errors
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        pageInfo = try? container.decode(PageInfo.self, forKey: .pageInfo)
        data = try container.decode(Element.self, forKey: .data)
        
        
        if let error = try? container.decode(ErrorMessageResponse.self, forKey: .errors) {
            errors?.append(ErrorsResponse(key: "message", value: error.message))
        }
        
        if let error = try? container.decode(ErrorDetailResponse.self, forKey: .errors) {
            errors?.append(ErrorsResponse(key: "message", value: error.detail))
        }
        
        /// todo: test it !
        if let errorsArr = try? container.decode([ErrorsResponse].self, forKey: .errors) {
            errorsArr.forEach {errors?.append($0)}
        }
        
        if let errorStrings = try? container.decode([String].self, forKey: .errors) {
            errorStrings.forEach { self.errorStrings?.append($0) }
        }
    }
    
    init(pageInfo: PageInfo?,
         data: Element?,
         errors: [ErrorsResponse]?,
         errorStrings: [String]?) {
        self.pageInfo = pageInfo
        self.data = data
        self.errors = errors
        self.errorStrings = errorStrings
    }
    
    private func getErrorDescription() -> String {
        if let keyValueErrors = errors, keyValueErrors.count > 0 {
            return keyValueErrors.compactMap({$0.value}).joined(separator: "\n")
        } else if let errorStrings = errorStrings {
            return errorStrings.joined(separator: "\n")
        }
        return NSLocalizedString("no errors", comment: "")
    }
}


