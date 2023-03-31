import UIKit
import Kingfisher
import ProgressHUD

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let imageSize = photos[indexPath.row].size
        
        let imageViewWeidth = tableView.bounds.width - 32
        let imageWidth = imageSize.width
        let scale = imageViewWeidth / imageWidth
        let imageViewHeight = imageSize.height * scale
        
        return imageViewHeight + 8
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
            imagesListService.fetchPhotosNextPage()
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imagesListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        imagesListCell.delegate = self
        configCell(for: imagesListCell, with: indexPath)
        return imagesListCell
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLike: photo.isLiked) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.photos = self.imagesListService.photos
                cell.setIsLiked(photoIsLiked: self.photos[indexPath.row].isLiked)
                UIBlockingProgressHUD.dismiss()
            case .failure(let error):
                UIBlockingProgressHUD.dismiss()
                print(error)
            }
        }
    }
}

final class ImagesListViewController: UIViewController {
    private var imagesListServiceObserver: NSObjectProtocol?
    private let imagesListService = ImagesListService.shared
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private var photos: [Photo] = []
    
    @IBOutlet private var tableView: UITableView!
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        imagesListServiceObserver = NotificationCenter.default
            .addObserver(forName: ImagesListService.DidChangeNotification,
                         object: nil,
                         queue: .main
            ) {[weak self] _ in
                guard let self = self else { return }
                self.updateTableViewAnimated()
            }
        if photos.isEmpty {
            self.imagesListService.fetchPhotosNextPage()
        }
    }
    
    private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if newCount != oldCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
    

    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        cell.prepareForReuse()
        let url = URL(string: photos[indexPath.row].thumbImageURL)
        let cache = ImageCache.default
        cache.diskStorage.config.expiration = .days(1)
        cell.cellImage.kf.indicatorType = .activity
        cell.cellImage.kf.setImage(with: url,
                                   placeholder: UIImage(named: "imagePlaceholder"),
                                   completionHandler: { [weak self] _ in
                                   self?.tableView.reloadRows(at: [indexPath], with: .automatic)})
        
        guard let photosDate = photos[indexPath.row].createdAt else { return }
        cell.dateLabel.text = dateFormatter.string(from: photosDate)
        
        let photoLike = photos[indexPath.row].isLiked
        
        if photoLike {
            cell.likeButton.imageView?.image = UIImage(named: "Like Active")
        } else {
            cell.likeButton.imageView?.image = UIImage(named: "Like Inactive")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard let viewController = segue.destination as? SingleImageViewController else { return }
            guard let indexPath = sender as? IndexPath else { return }
            let url = photos[indexPath.row].largeImageURL
            viewController.fullImageUrl = url
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

