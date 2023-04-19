import Foundation
import ImageFeed
import UIKit

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ProfilePresenterProtocol?
    var showAlertCalled: Bool = false
    
    func updateAvatar(url: URL) { }
    func presentAuthViewController(authViewController: UIViewController) { }
    func updateProfileDetails(name: String, login: String, bio: String) { }
    
    func showAlert(alert: UIAlertController) {
        showAlertCalled = true
    }
}
