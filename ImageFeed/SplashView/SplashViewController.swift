import Foundation
import UIKit
import ProgressHUD

final class SplashViewController: UIViewController, AuthViewControllerDelegate {
    
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    
    private let oAuth2Service = OAuth2Service()
    private let oAuth2TokenStorage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if oAuth2TokenStorage.token != nil {
            fetchProfile(token: oAuth2TokenStorage.token ?? "")
        } else {
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            guard let navigationController = segue.destination as? UINavigationController,
                  let viewController = navigationController.viewControllers[0] as? AuthViewController
            else { fatalError("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)") }
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
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
            case .failure:
                UIBlockingProgressHUD.dismiss()
                self.showAlert()
                break
            }
        }
    }
    
    private func fetchProfile(token: String) {
        profileService.fetchProfile(token) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                UIBlockingProgressHUD.dismiss()
                self.switchToTabBarController()
                self.fetchProfileImageURL(username: self.profileService.profile?.userName ?? "")
            case .failure:
                UIBlockingProgressHUD.dismiss()
                self.showAlert()
                break
            }
        }
    }
    
    private func fetchProfileImageURL(username: String) {
        ProfileImageService.shared.fetchProfileImageURL(username) { result in
            switch result {
            case .success(let avatarURL):
                print(avatarURL)
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
