import Foundation
import UIKit
import ProgressHUD

public protocol SplashViewControllerProtocol: AnyObject {
    var presenter: SplashPresenterProtocol? { get set }
    func showAuthViewController()
    func switchToTabBarController()
    func showAlert()
    func showProgressHUD()
    func hideProgressHUD()
    func fetchProfileImageURL(username: String)
}

final class SplashViewController: UIViewController, SplashViewControllerProtocol {
    var presenter: SplashPresenterProtocol?
    private let oAuth2Service = OAuth2Service()
    static let DidChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter?.viewDidAppear()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func showAuthViewController() {
        guard let authViewController = UIStoryboard(name: "Main",bundle: .main
        ).instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else { return }
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true, completion: nil)
    }
    
    func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarController")
        window.rootViewController = tabBarController
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "Что-то пошло не так(",
                                      message: "Не удалось войти в систему",
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: "ОК", style: .default) {_ in
            alert.dismiss(animated: true)
        }
        alert.addAction(action)
        self.present(alert, animated: true)
    }
    
    func showProgressHUD() {
        UIBlockingProgressHUD.show()
    }
    
    func hideProgressHUD() {
        UIBlockingProgressHUD.dismiss()
    }
    
    func fetchProfileImageURL(username: String) {
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
    
    private func setupUI() {
        view.backgroundColor = .ypBlack
        let vector = UIImageView()
        vector.image = UIImage(named: "Vector")
        view.addSubview(vector)
        vector.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            vector.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            vector.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

//MARK: - AuthViewControllerDelegate
extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        showProgressHUD()
        oAuth2Service.fetchAuthToken(code) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let token):
                self.presenter?.fetchProfile(token: token)
            case .failure(let error):
                self.hideProgressHUD()
                self.showAlert()
                print(error)
                break
            }
        }
    }
}
