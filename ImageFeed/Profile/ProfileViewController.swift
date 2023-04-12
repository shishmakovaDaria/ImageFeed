import Foundation
import UIKit
import Kingfisher
import WebKit

public protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol? { get set }
    func updateAvatar(url: URL)
    func updateProfileDetails(name: String, login: String, bio: String)
    func presentAuthViewController(authViewController: UIViewController)
    func showAlert(alert: UIAlertController)
}

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
    var presenter: ProfilePresenterProtocol?
    private var alertPresenter: AlertPresenterProtocol?
    private lazy var profilePhoto = UIImageView()
    private lazy var nameLabel = UILabel()
    private lazy var nickNameLabel = UILabel()
    private lazy var statusLabel = UILabel()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alertPresenter = AlerPresenter(viewController: self)
        
        view.backgroundColor = .ypBlack
        addProfilePhoto()
        addLogOutButton()
        addLabels()
        
        presenter?.viewDidLoad()
    }
    
    func updateAvatar(url: URL) {
        let cache = ImageCache.default
        cache.diskStorage.config.expiration = .days(30)
        let processor = RoundCornerImageProcessor(cornerRadius: 61, backgroundColor: .clear)
        profilePhoto.kf.indicatorType = .activity
        profilePhoto.kf.setImage(with: url,
                                 placeholder: UIImage(named: "placeholder"),
                                 options: [.processor(processor),
                                           .cacheSerializer(FormatIndicatedCacheSerializer.png)])
        profilePhoto.backgroundColor = .clear
    }
    
    func updateProfileDetails(name: String, login: String, bio: String) {
        nameLabel.text = name
        nickNameLabel.text = login
        statusLabel.text = bio
    }
    
    func presentAuthViewController(authViewController: UIViewController) {
        self.present(authViewController, animated: true, completion: nil)
    }
    
    func showAlert(alert: UIAlertController) {
        self.present(alert, animated: true)
    }
    
    @IBAction private func logOutButtonDidTap(_ sender: Any?) {
        alertPresenter?.makeLogOutAlert()
    }
    
    private func addProfilePhoto() {
        profilePhoto.image = UIImage(named: "Photo")
        profilePhoto.clipsToBounds = true
        view.addSubview(profilePhoto)
        profilePhoto.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profilePhoto.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            profilePhoto.topAnchor.constraint(equalTo: view.topAnchor, constant: 76),
            profilePhoto.heightAnchor.constraint(equalToConstant: 70),
            profilePhoto.widthAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    private func addLogOutButton() {
        let logOutButton = UIButton.systemButton(
            with: UIImage(named: "ipad.and.arrow.forward")!,
            target: self,
            action: nil)
        logOutButton.addTarget(self, action: #selector(logOutButtonDidTap(_:)), for: .touchUpInside)
        
        logOutButton.tintColor = .ypRed
        view.addSubview(logOutButton)
        logOutButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            logOutButton.centerYAnchor.constraint(equalTo: profilePhoto.centerYAnchor),
            logOutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -26),
            logOutButton.widthAnchor.constraint(equalToConstant: 20),
            logOutButton.heightAnchor.constraint(equalToConstant: 22)
        ])
    }
    
    private func addLabels() {
        nameLabel.text = "Екатерина Новикова"
        nickNameLabel.text = "@ekaterina_nov"
        statusLabel.text = "Hello, world!"
        
        nameLabel.font = UIFont.boldSystemFont(ofSize: 23)
        nickNameLabel.font = UIFont.systemFont(ofSize: 13)
        statusLabel.font = UIFont.systemFont(ofSize: 13)
        
        nameLabel.textColor = .ypWhite
        nickNameLabel.textColor = .ypGray
        statusLabel.textColor = .ypWhite
        
        
        view.addSubview(nameLabel)
        view.addSubview(nickNameLabel)
        view.addSubview(statusLabel)
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nickNameLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: profilePhoto.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: profilePhoto.leadingAnchor),
            nickNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            nickNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            statusLabel.topAnchor.constraint(equalTo: nickNameLabel.bottomAnchor, constant: 8),
            statusLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor)
        ])
    }
}
