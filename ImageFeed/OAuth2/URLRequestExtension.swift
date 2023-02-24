import Foundation

extension URLRequest {
    static func makeHTTPRequest(
        path: String,
        httpMethod: String,
        baseURL: URL = Constants.DefaultBaseURL
    ) -> URLRequest {
        var request = URLRequest(url: URL(string: path, relativeTo: baseURL)!)
        request.httpMethod = httpMethod
        return request
    }
}
