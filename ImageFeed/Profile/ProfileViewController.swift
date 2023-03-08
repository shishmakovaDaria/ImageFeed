import Foundation
import UIKit

final class ProfileViewController: UIViewController {
    
    private let profilePhoto = UIImageView()    
    private var nameLabel = UILabel()
    private var nickNameLabel = UILabel()
    private var statusLabel = UILabel()
    private let profileService = ProfileService.shared
    private let profile = ProfileService.shared.profile
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        addProfilePhoto()
        addLogOutButton()
        addLabels()
        guard let profile = profile else { return }
        updateProfileDetails(profile: profile)
    }
    
    private func updateProfileDetails(profile: Profile) {
        nameLabel.text = profile.name
        nickNameLabel.text = profile.loginName
        statusLabel.text = profile.bio
    }
    
    private func addProfilePhoto() {
        profilePhoto.image = UIImage(named: "Photo")
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
