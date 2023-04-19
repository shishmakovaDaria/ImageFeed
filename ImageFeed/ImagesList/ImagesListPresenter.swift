import Foundation

public protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    var photos: [Photo] { get }
    
    func viewDidLoad()
    func makePhotoUrl(photoNumber: Int) -> URL?
    func loadNextPhotos(row: Int)
    func makePhotoDate(row: Int) -> String
    func changeLike(cell: ImagesListCell, row: Int)
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    var photos: [Photo] = []
    private let imagesListService = ImagesListService.shared
    private var imagesListServiceObserver: NSObjectProtocol?
    
    func viewDidLoad() {
        if photos.isEmpty {
            self.imagesListService.fetchPhotosNextPage()
        }
        
        imagesListServiceObserver = NotificationCenter.default
            .addObserver(forName: ImagesListService.DidChangeNotification,
                         object: nil,
                         queue: .main
            ) {[weak self] _ in
                guard let self = self else { return }
                let oldCount = self.photos.count
                let newCount = self.imagesListService.photos.count
                self.photos = self.imagesListService.photos
                if newCount != oldCount {
                    self.view?.updateTableViewAnimated(oldCount: oldCount, newCount: newCount)
                }
            }
    }
    
    func makePhotoUrl(photoNumber: Int) -> URL? {
        let url = URL(string: photos[photoNumber].thumbImageURL)
        return url
    }
    
    func loadNextPhotos(row: Int) {
        if row == photos.count - 1 {
            imagesListService.fetchPhotosNextPage()
        }
    }
    
    func makePhotoDate(row: Int) -> String {
        guard let photosDate = photos[row].createdAt else { return "" }
        let dateString = dateFormatter.string(from: photosDate)
        return dateString
    }
    
    func changeLike(cell: ImagesListCell, row: Int) {
        let photo = photos[row]
        imagesListService.changeLike(photoId: photo.id, isLike: photo.isLiked) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.photos = self.imagesListService.photos
                cell.setIsLiked(photoIsLiked: self.photos[row].isLiked)
            case .failure(let error):
                print(error)
            }
            self.view?.hideProgressHUD()
        }
    }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
}
