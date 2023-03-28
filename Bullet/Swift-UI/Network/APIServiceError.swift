import Foundation

enum APIServiceError: Error {
    case apiReturnErrorsList(_ errors: [ErrorsResponse], Int?)
    case apiReturnErrorsStringList(_ errors: [String], Int?)
    case apiError(Int)
    case invalidToken
    case noData
    case noResponse
    case noDataInContainer
    case decodeError(Error?)
    case requestError(error: Error)
    case unsupportedDataError
    
    func getDescription() -> String{
        switch self {
        case .apiError:
            return "Something went wrong. Try again later."
        case .invalidToken:
            return "Looks like there's a problem with your Authentication"
        case .requestError(let err):
            return "\(err.localizedDescription)"
        case .unsupportedDataError:
            return "Response contained an unknown error"
        case .noData:
            return "No data was received"
        case .noResponse:
            return "No response received"
        case .noDataInContainer:
            return "No data found in the Response Container"
        case .decodeError:
            return "Invalid data received."
        case .apiReturnErrorsList(let errors, _):
            return errors.compactMap({$0.value}).joined(separator: "\n")
        case .apiReturnErrorsStringList(let errors, _):
            return errors.joined(separator: "\n")
        }
    }
    
    var statusCode: Int? {
        switch self {
        case .apiError(let code):
            return code
        case .apiReturnErrorsList(_, let code):
            return code
        case .apiReturnErrorsStringList(_, let code):
            return code
        default:
            return nil
        }
    }
}
