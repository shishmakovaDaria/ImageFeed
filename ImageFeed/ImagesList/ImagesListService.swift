import Foundation

final class ImagesListService {
    private (set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    static let DidChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    private var task: URLSessionTask?
    
    func fetchPhotosNextPage(completion: @escaping (Result<[Photo], Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        let nextPage = lastLoadedPage == nil
        ? 1
        : lastLoadedPage ?? 0 + 1
        guard let imagesRequest = URLRequest.makeHTTPRequest(path: "/photos/\(nextPage)", httpMethod: "GET") else { return }
        let task = URLSession.shared.objectTask(for: imagesRequest) {[weak self] (result: Result<PhotoResult, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let body):
                let id = body.id
                let size = CGSize(width: body.width, height: body.height)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                let createdAt = dateFormatter.date(from: body.createdAt)
                let welcomeDescription = body.welcomeDescription
                let thumbImageURL = body.urls.thumb
                let largeImageURL = body.urls.full
                let isLiked = body.isLiked
                let newImageList = Photo(id: id, size: size, createdAt: createdAt, welcomeDescription: welcomeDescription, thumbImageURL: thumbImageURL, largeImageURL: largeImageURL, isLiked: isLiked)
                self.photos.append(newImageList)
                completion(.success(self.photos))
                NotificationCenter.default
                    .post(
                        name: ImagesListService.DidChangeNotification,
                        object: self,
                        userInfo: ["newPhotos": self.photos])
            case .failure(let error):
                completion(.failure(error))
            }
        }
        task.resume()
        self.task = task
    }
}

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

struct PhotoResult: Codable {
    let id: String
    let createdAt: String
    let width: Int
    let height: Int
    let isLiked: Bool
    let welcomeDescription: String
    let urls: UrlsResult
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case width
        case height
        case isLiked = "liked_by_user"
        case welcomeDescription = "description"
        case urls
    }
}

struct UrlsResult: Codable {
    let full: String
    let thumb: String
    
    enum CodingKeys: String, CodingKey {
        case full
        case thumb
    }
}
