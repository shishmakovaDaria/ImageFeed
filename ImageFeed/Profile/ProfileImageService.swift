import Foundation

final class ProfileImageService {
    
    static let shared = ProfileImageService()
    private var task: URLSessionTask?
    private (set) var avatarURL: String?
    
    func fetchProfileImageURL(
        _ username: String,
        _ completion: @escaping (Result<String, Error>) -> Void
    ) {
        assert(Thread.isMainThread)
        task?.cancel()
        guard var profileImageRequest = URLRequest.makeHTTPRequest(path: "/users/\(username)", httpMethod: "GET") else  { return }
        profileImageRequest.setValue("Bearer \(OAuth2TokenStorage().token ?? "")", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.objectTask(for: profileImageRequest) { [weak self] (result: Result<UserResult, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let body):
                let avatarURL = body.profileImage?.large
                self.avatarURL = avatarURL
                completion(.success(avatarURL ?? ""))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        task.resume()
        self.task = task
    }
}

struct UserResult: Codable {
    let profileImage: ProfileImageUrl?
    
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
