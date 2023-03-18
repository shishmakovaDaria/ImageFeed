import Foundation

final class ProfileService {
    
    static let shared = ProfileService()
    
    private(set) var profile: Profile?
    
    private var task: URLSessionTask?
    
    func fetchProfile(
        _ token: String,
        completion: @escaping (Result<Profile, Error>) -> Void
    ) {
        assert(Thread.isMainThread)
        task?.cancel()
        guard var profileRequest = URLRequest.makeHTTPRequest(path: "/me", httpMethod: "GET") else { return }
        profileRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.objectTask(for: profileRequest) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let body):
                let userName = body.userName
                let name = "\(body.firstName) \(body.lastName)"
                let loginName = "@\(body.userName)"
                let bio = body.bio
                let profile = Profile(userName: userName, name: name, loginName: loginName, bio: bio)
                self.profile = profile
                completion(.success(profile))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        task.resume()
        self.task = task
    }
}

struct ProfileResult: Codable {
    let userName: String
    let firstName: String
    let lastName: String
    let bio: String
    
    enum CodingKeys: String, CodingKey {
        case userName = "username"
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
}

struct Profile { // будем использовать в UI-коде
    let userName: String // логин пользователя в том же виде, в каком мы получаем его от сервиса
    let name: String // конкатенация имени и фамилии пользователя (если first_name = "Ivan", last_name = "Ivanov", то name = "Ivan Ivanov")
    let loginName: String // username со знаком @ перед первым символом (если username = "ivanivanov", то loginName = "@ivanivanov")
    let bio: String // совпадает с bio из ProfileResult
}
