import Foundation
import UIKit

protocol AlertPresenterProtocol {
    var viewController: ProfileViewControllerProtocol? { get set }
    func showLogOutAlert()
}

final class AlerPresenter: AlertPresenterProtocol {
    weak var viewController: ProfileViewControllerProtocol?
    
    init(viewController: ProfileViewControllerProtocol) {
        self.viewController = viewController
    }
    
    func showLogOutAlert() {
        let alert = UIAlertController(title: "Пока, пока!",
                                      message: "Уверены, что хотите выйти?",
                                      preferredStyle: .alert)
        
        let action1 = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            guard let self = self else { return }
            ProfilePresenter.cleanCookiesAndToken()
            self.viewController?.presentAuthViewController()
        }
        
        let action2 = UIAlertAction(title: "Нет", style: .default) {_ in
            alert.dismiss(animated: true)
        }
        
        alert.addAction(action1)
        alert.addAction(action2)
        viewController?.showAlert(alert: alert)
    }
}
