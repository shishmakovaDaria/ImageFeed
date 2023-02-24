import Foundation

final class OAuth2Service {
    
    static let shared = OAuth2Service()
    
    private let oAuth2TokenStorage = OAuth2TokenStorage()
    
    private (set) var authToken: String? {
        get {
            return oAuth2TokenStorage.token
        }
        set {
            oAuth2TokenStorage.token = newValue
        }
    }
    
    private func authTokenRequest(code: String) -> URLRequest {
        URLRequest.makeHTTPRequest(
            path: {
                guard var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token") else { return "" }
                urlComponents.queryItems = [
                    URLQueryItem(name: "client_id", value: Constants.AccessKey),
                    URLQueryItem(name: "client_secret", value: Constants.SecretKey),
                    URLQueryItem(name: "redirect_uri", value: Constants.RedirectURI),
                    URLQueryItem(name: "code", value: code),
                    URLQueryItem(name: "grant_type", value: "authorization_code")
                ]
                guard let url = urlComponents.url else { return "" }
                return url.absoluteString
            }(),
            httpMethod: "POST"
        )
    }
    
    private func object(
        for request: URLRequest,
        completion: @escaping (Result<OAuthTokenResponseBody, Error>) -> Void
    ) -> URLSessionTask {
        return URLSession.shared.data(for: request) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                do {
                    let object = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                    completion(.success(object))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchAuthToken(
        _ code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let request = authTokenRequest(code: code)
        _ = object(for: request) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let body):
                let authToken = body.accessToken
                self.authToken = authToken
                completion(.success(authToken))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
