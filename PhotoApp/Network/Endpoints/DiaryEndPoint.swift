
import Foundation

enum DiaryEndPoint {
    case postData(request: DiaryRequest.Request)
}

extension DiaryEndPoint: Endpoint {
    var path: String {
        switch self {
        case .postData:
            return "/api/users"
        }
    }
    
    var method: RequestMethod {
        switch self {
        case .postData:
            return .post
        }
    }
    
    var header: [String: String]? {
        switch self {
        case .postData:
            return [
                "Content-Type": "application/json;charset=utf-8"
            ]
        }
    }
    
    var body: [String: String]? {
        switch self {
        case .postData(let mod):
            return ["name": mod.name,
                    "job" : mod.job
            ]
        }
    }
}
