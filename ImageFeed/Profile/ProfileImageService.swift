import Foundation

final class ProfileImageService {
    
    static let shared = ProfileImageService()
    private var task: URLSessionTask?
    private (set) var avatarURL: String?
    static let DidChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    func fetchProfileImageURL(
        _ username: String,
        _ completion: @escaping (Result<String, Error>) -> Void
    ) {
        assert(Thread.isMainThread)
        task?.cancel()
        var profileImageRequest = URLRequest.makeHTTPRequest(path: "/users/\(username)", httpMethod: "GET")
        profileImageRequest.setValue("Bearer \(OAuth2TokenStorage().token ?? "")", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.objectTask(for: profileImageRequest) { [weak self] (result: Result<UserResult, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let body):
                    let avatarURL = body.profileImage.small
                    self.avatarURL = avatarURL
                    print("А В А Т А Р  П Р О Ф И Л Я  П О Л У Ч Е Н ")
                    completion(.success(avatarURL))
                    NotificationCenter.default
                        .post(
                            name: ProfileImageService.DidChangeNotification,
                            object: self,
                            userInfo: ["URL": avatarURL])
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        self.task = task
    }
}

struct UserResult: Codable {
    let profileImage: ProfileImageUrl
    
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

struct ProfileImageUrl: Codable {
    let small: String
    let medium: String
    let large: String
    
    enum CodingKeys: String, CodingKey {
        case small
        case medium
        case large
    }
}
