import Foundation
import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    
    static let reuseIdentifier = "ImagesListCell"
    weak var delegate: ImagesListCellDelegate?
    
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var cellImage: UIImageView!
    
    @IBAction private func likeButtonClicked(_ sender: Any) {
        delegate?.imageListCellDidTapLike(self)
    }
    
    func makeGradient() {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.ypBlack.withAlphaComponent(0.0).cgColor, UIColor.ypBlack.withAlphaComponent(0.2).cgColor]
        gradient.locations = [0,1]
        gradient.frame = self.gradientView.bounds
        self.gradientView.layer.insertSublayer(gradient, at: 0)
    }
    
    func setIsLiked(photoIsLiked: Bool) {
        if photoIsLiked {
            likeButton.imageView?.image = UIImage(named: "Like Active")
        } else {
            likeButton.imageView?.image = UIImage(named: "Like Inactive")
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.makeGradient()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
    }
}
