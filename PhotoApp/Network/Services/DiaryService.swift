import Foundation

protocol DiaryNoteServiceable {
    func postDiaryData(request: DiaryRequest.Request) async -> Result<DiaryRequest.Response, RequestError>
}

struct DiaryService: HTTPClient, DiaryNoteServiceable {
    var httpClient: HTTPClient?
    func postDiaryData(request: DiaryRequest.Request) async -> Result<DiaryRequest.Response, RequestError> {
        return await sendRequest(endpoint: DiaryEndPoint.postData(request: request), responseModel: DiaryRequest.Response.self)
    }
}

struct DiaryRequest: Codable {
    
    struct Request {
        var name: String
        var job: String
    }
    
    struct Response: Codable {
        var name: String
        var job : String
        var id : String
        var createdAt : String
    }
}
