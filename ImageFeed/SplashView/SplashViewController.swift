import Foundation
import UIKit
import ProgressHUD

final class SplashViewController: UIViewController, AuthViewControllerDelegate {
    
    private let oAuth2Service = OAuth2Service()
    private let oAuth2TokenStorage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
    static let DidChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if oAuth2TokenStorage.token != nil {
            fetchProfile(token: oAuth2TokenStorage.token ?? "")
        } else {
            guard let authViewController = UIStoryboard(name: "Main",bundle: .main
            ).instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else { return }
            authViewController.delegate = self
            authViewController.modalPresentationStyle = .fullScreen
            present(authViewController, animated: true, completion: nil)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        addVector()
    }
    
    private func addVector() {
        let vector = UIImageView()
        vector.image = UIImage(named: "Vector")
        view.addSubview(vector)
        vector.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            vector.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            vector.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarController")
        window.rootViewController = tabBarController
    }
    
    //MARK: - AuthViewControllerDelegate
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        ProgressHUD.animationType = .circleRotateChase
        UIBlockingProgressHUD.show()
        oAuth2Service.fetchAuthToken(code) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let token):
                self.fetchProfile(token: token)
            case .failure(let error):
                UIBlockingProgressHUD.dismiss()
                self.showAlert()
                print(error)
                break
            }
        }
    }
    
    private func fetchProfile(token: String) {
        profileService.fetchProfile(token) { [weak self] result in
            guard let self = self else { return }
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success:
                self.switchToTabBarController()
                self.fetchProfileImageURL(username: self.profileService.profile?.userName ?? "")
            case .failure(let error):
                self.showAlert()
                print(error)
            }
        }
    }
    
    private func fetchProfileImageURL(username: String) {
        ProfileImageService.shared.fetchProfileImageURL(username) { result in
            switch result {
            case .success(let avatarURL):
                NotificationCenter.default
                    .post(
                        name: SplashViewController.DidChangeNotification,
                        object: self,
                        userInfo: ["URL": avatarURL])
            case .failure(let error):
                print(error)
                break
            }
        }
    }
    
    private func showAlert() {
        let alert = UIAlertController(title: "Что-то пошло не так(",
                                      message: "Не удалось войти в систему",
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: "ОК", style: .default) {_ in
            alert.dismiss(animated: true)
        }
        alert.addAction(action)
        self.present(alert, animated: true)
    }
}
