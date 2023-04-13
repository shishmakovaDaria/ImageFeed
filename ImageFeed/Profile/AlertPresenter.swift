import Foundation
import UIKit

protocol AlertPresenterProtocol {
    var viewController: ProfileViewControllerProtocol? { get set }
    func makeLogOutAlert()
}

final class AlertPresenter: AlertPresenterProtocol {
    weak var viewController: ProfileViewControllerProtocol?
    private let splashViewController = SplashViewController()
    
    init(viewController: ProfileViewControllerProtocol) {
        self.viewController = viewController
    }
    
    func makeLogOutAlert() {
        let alert = UIAlertController(title: "Пока, пока!",
                                      message: "Уверены, что хотите выйти?",
                                      preferredStyle: .alert)
        
        let action1 = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            guard let self = self else { return }
            ProfilePresenter.cleanCookiesAndToken()
            
            guard let authViewController = UIStoryboard(name: "Main",bundle: .main
            ).instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else { return }
            authViewController.delegate = self.splashViewController
            authViewController.modalPresentationStyle = .fullScreen
            self.viewController?.presentAuthViewController(authViewController: authViewController)
        }
        
        let action2 = UIAlertAction(title: "Нет", style: .default) {_ in
            alert.dismiss(animated: true)
        }
        
        alert.addAction(action1)
        alert.addAction(action2)
        viewController?.showAlert(alert: alert)
    }
}
