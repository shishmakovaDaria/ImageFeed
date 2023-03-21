import Foundation

final class ImagesListService {
    private (set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    static let DidChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    private var task: URLSessionTask?
    
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        task?.cancel()
        let nextPage = lastLoadedPage == nil
        ? 1
        : (lastLoadedPage ?? 0) + 1
        guard var imagesRequest = URLRequest.makeHTTPRequest(path: "/photos?page=\(nextPage)", httpMethod: "GET") else { return }
        imagesRequest.setValue("Client-ID \(Constants.accessKey)", forHTTPHeaderField: "Authorization")
        print(imagesRequest)
        let task = URLSession.shared.objectTask(for: imagesRequest) {[weak self] (result: Result<Array<PhotoResult>, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let body):
                for i in 0..<body.count {
                    let id = body[i].id
                    let size = CGSize(width: body[i].width, height: body[i].height)
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                    let createdAt = dateFormatter.date(from: body[i].createdAt)
                    let welcomeDescription = body[i].welcomeDescription
                    let thumbImageURL = body[i].urls.thumb
                    let largeImageURL = body[i].urls.full
                    let isLiked = body[i].isLiked
                    let newPhoto = Photo(id: id, size: size, createdAt: createdAt, welcomeDescription: welcomeDescription, thumbImageURL: thumbImageURL, largeImageURL: largeImageURL, isLiked: isLiked)
                    self.photos.append(newPhoto)
                }
                NotificationCenter.default
                    .post(
                        name: ImagesListService.DidChangeNotification,
                        object: self,
                        userInfo: ["newPhotos": self.photos])
            case .failure(let error):
                print(error)
            }
        }
        task.resume()
        self.task = task
        if lastLoadedPage == nil {
            lastLoadedPage = 1
        } else {
            lastLoadedPage? += 1
        }
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
    let welcomeDescription: String?
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
