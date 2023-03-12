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
    
    private var task: URLSessionTask?
    private var lastCode: String?
    
    private func authTokenRequest(code: String) -> URLRequest? {
        var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token")
        urlComponents?.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.AccessKey),
            URLQueryItem(name: "client_secret", value: Constants.SecretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.RedirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        guard let url = urlComponents?.url else { return nil}
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    func fetchAuthToken(
        _ code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        assert(Thread.isMainThread)
        if lastCode == code { return }
        task?.cancel()
        lastCode = code
        let request = authTokenRequest(code: code)
        if let request = request {
            let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    switch result {
                    case .success(let body):
                        let authToken = body.accessToken
                        self.authToken = authToken
                        completion(.success(authToken))
                        self.task = nil
                    case .failure(let error):
                        completion(.failure(error))
                        self.lastCode = nil
                    }
                }
            }
            self.task = task
        }
    }
}
