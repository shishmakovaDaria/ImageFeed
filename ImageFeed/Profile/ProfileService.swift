import Foundation

final class ProfileService {
    private func object(
        for request: URLRequest,
        completion: @escaping (Result<ProfileResult, Error>) -> Void
    ) -> URLSessionTask {
        return URLSession.shared.data(for: request) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                do {
                    let object = try JSONDecoder().decode(ProfileResult.self, from: data)
                    completion(.success(object))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchProfile(
        _ token: String,
        completion: @escaping (Result<Profile, Error>) -> Void
    ) {
        var profileRequest = URLRequest.makeHTTPRequest(path: "/me", httpMethod: "GET")
        profileRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let _ = object(for: profileRequest) { result in
            switch result {
            case .success(let body):
                let userName = body.userName
                let name = "\(body.firstName) \(body.lastName)"
                let loginName = "@\(body.userName)"
                let bio = body.bio
                completion(.success(Profile(userName: userName, name: name, loginName: loginName, bio: bio)))
            case .failure(let error):
                completion(.failure(error))
            }
        }
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
