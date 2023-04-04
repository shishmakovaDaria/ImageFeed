import Foundation
import UIKit
import Kingfisher
import WebKit

final class ProfileViewController: UIViewController {
    
    private lazy var profilePhoto = UIImageView()
    private lazy var nameLabel = UILabel()
    private lazy var nickNameLabel = UILabel()
    private lazy var statusLabel = UILabel()
    private let profileService = ProfileService.shared
    private let profile = ProfileService.shared.profile
    private var profileImageServiceObserver: NSObjectProtocol?
    private let splashViewController = SplashViewController()
    private var animationLayers = Set<CALayer>()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        addGradient()
        addProfilePhoto()
        addLogOutButton()
        addLabels()
        guard let profile = profile else { return }
        updateProfileDetails(profile: profile)
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: SplashViewController.DidChangeNotification,
                object: nil,
                queue: .main
            ) {[weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        updateAvatar()
    }
    
    private func updateAvatar() {
        guard let avatarURL = ProfileImageService.shared.avatarURL,
              let url = URL(string: avatarURL)
        else { return }
        let cache = ImageCache.default
        cache.diskStorage.config.expiration = .days(30)
        let processor = RoundCornerImageProcessor(cornerRadius: 61, backgroundColor: .clear)
        profilePhoto.kf.setImage(with: url,
                                 options: [.processor(processor),
                                           .cacheSerializer(FormatIndicatedCacheSerializer.png)],
                                 completionHandler: { [weak self] _ in
                                     guard let self = self else { return }
                                     for animation in self.animationLayers {
                                         animation.removeFromSuperlayer()
                                     }
                                     self.nameLabel.textColor = .ypWhite
                                     self.nickNameLabel.textColor = .ypGray
                                     self.statusLabel.textColor = .ypWhite
                                     self.nameLabel.font = UIFont.boldSystemFont(ofSize: 23)
                                  } )
        profilePhoto.backgroundColor = .clear
    }
    
    private func updateProfileDetails(profile: Profile) {
        nameLabel.text = profile.name
        nickNameLabel.text = profile.loginName
        statusLabel.text = profile.bio
    }
    
    @IBAction private func logOutButtonDidTap(_ sender: Any?) {
        OAuth2TokenStorage().token = nil
        ProfileViewController.clean()
        guard let authViewController = UIStoryboard(name: "Main",bundle: .main
        ).instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else { return }
        authViewController.delegate = splashViewController
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true, completion: nil)
    }
    
    static func clean() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
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
        
        nameLabel.font = UIFont.boldSystemFont(ofSize: 13)
        nickNameLabel.font = UIFont.systemFont(ofSize: 13)
        statusLabel.font = UIFont.systemFont(ofSize: 13)
        
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
    
    private func addGradient() {
        nameLabel.textColor = .ypBlack
        nickNameLabel.textColor = .ypBlack
        statusLabel.textColor = .ypBlack
        
        let gradientColors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(origin: .zero, size: CGSize(width: 70, height: 70))
        gradient.locations = [0, 0.1, 0.3]
        gradient.colors = gradientColors
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = 35
        gradient.masksToBounds = true
        animationLayers.insert(gradient)
        profilePhoto.layer.addSublayer(gradient)
        
        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 1.0
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]
        gradient.add(gradientChangeAnimation, forKey: "locationsChange")
        
        let labelGradient1 = CAGradientLayer()
        labelGradient1.frame = CGRect(origin: .zero, size: CGSize(width: 223, height: 18))
        labelGradient1.locations = [0, 0.1, 0.3]
        labelGradient1.colors = gradientColors
        labelGradient1.startPoint = CGPoint(x: 0, y: 0.5)
        labelGradient1.endPoint = CGPoint(x: 1, y: 0.5)
        labelGradient1.cornerRadius = 9
        labelGradient1.masksToBounds = true
        animationLayers.insert(labelGradient1)
        nameLabel.layer.addSublayer(labelGradient1)
        
        let labelGradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        labelGradientChangeAnimation.duration = 1.0
        labelGradientChangeAnimation.repeatCount = .infinity
        labelGradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        labelGradientChangeAnimation.toValue = [0, 0.8, 1]
        labelGradient1.add(labelGradientChangeAnimation, forKey: "locationsChange")
        
        let labelGradient2 = CAGradientLayer()
        labelGradient2.frame = CGRect(origin: .zero, size: CGSize(width: 89, height: 18))
        labelGradient2.locations = [0, 0.1, 0.3]
        labelGradient2.colors = gradientColors
        labelGradient2.startPoint = CGPoint(x: 0, y: 0.5)
        labelGradient2.endPoint = CGPoint(x: 1, y: 0.5)
        labelGradient2.cornerRadius = 9
        labelGradient2.masksToBounds = true
        animationLayers.insert(labelGradient2)
        nickNameLabel.layer.addSublayer(labelGradient2)
        
        let labelGradientChangeAnimation2 = CABasicAnimation(keyPath: "locations")
        labelGradientChangeAnimation2.duration = 1.0
        labelGradientChangeAnimation2.repeatCount = .infinity
        labelGradientChangeAnimation2.fromValue = [0, 0.1, 0.3]
        labelGradientChangeAnimation2.toValue = [0, 0.8, 1]
        labelGradient2.add(labelGradientChangeAnimation2, forKey: "locationsChange")
        
        let labelGradient3 = CAGradientLayer()
        labelGradient3.frame = CGRect(origin: .zero, size: CGSize(width: 67, height: 18))
        labelGradient3.locations = [0, 0.1, 0.3]
        labelGradient3.colors = gradientColors
        labelGradient3.startPoint = CGPoint(x: 0, y: 0.5)
        labelGradient3.endPoint = CGPoint(x: 1, y: 0.5)
        labelGradient3.cornerRadius = 9
        labelGradient3.masksToBounds = true
        animationLayers.insert(labelGradient3)
        statusLabel.layer.addSublayer(labelGradient3)
        
        let labelGradientChangeAnimation3 = CABasicAnimation(keyPath: "locations")
        labelGradientChangeAnimation3.duration = 1.0
        labelGradientChangeAnimation3.repeatCount = .infinity
        labelGradientChangeAnimation3.fromValue = [0, 0.1, 0.3]
        labelGradientChangeAnimation3.toValue = [0, 0.8, 1]
        labelGradient3.add(labelGradientChangeAnimation3, forKey: "locationsChange")
    }
}
