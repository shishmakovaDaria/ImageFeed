import Foundation
import UIKit

protocol AlertPresenterProtocol {
    var viewController: ProfileViewControllerProtocol? { get set }
    func makeLogOutAlert()
}

final class AlertPresenter: AlertPresenterProtocol {
    weak var viewController: ProfileViewControllerProtocol?
    private let splashViewController = SplashViewController()
    private let splashPresenter = SplashPresenter()
    
    init(viewController: ProfileViewControllerProtocol) {
        self.viewController = viewController
    }
    
    func makeLogOutAlert() {
        let alert = UIAlertController(title: "Пока, пока!",
                                      message: "Уверены, что хотите выйти?",
                                      preferredStyle: .alert)
        alert.view.accessibilityIdentifier = "Bye bye!"
        
        let action1 = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            guard let self = self else { return }
            ProfilePresenter.cleanCookiesAndToken()
            
            guard let authViewController = UIStoryboard(name: "Main",bundle: .main
            ).instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else { return }
            splashViewController.presenter = splashPresenter
            splashPresenter.view = splashViewController
            authViewController.delegate = self.splashViewController
            authViewController.modalPresentationStyle = .fullScreen
            self.viewController?.presentAuthViewController(authViewController: authViewController)
        }
        action1.accessibilityIdentifier = "Yes"
        
        let action2 = UIAlertAction(title: "Нет", style: .default) {_ in
            alert.dismiss(animated: true)
        }
        
        alert.addAction(action1)
        alert.addAction(action2)
        viewController?.showAlert(alert: alert)
    }
}
