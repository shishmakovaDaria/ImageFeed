import Foundation
import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var cellImage: UIImageView!
    
    func makeGradient() {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.ypBlack.withAlphaComponent(0.0).cgColor, UIColor.ypBlack.withAlphaComponent(0.2).cgColor]
        gradient.locations = [0,1]
        gradient.frame = self.gradientView.bounds
        self.gradientView.layer.insertSublayer(gradient, at: 0)
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
