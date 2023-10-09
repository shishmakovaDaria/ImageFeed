import Foundation

public protocol SplashPresenterProtocol: AnyObject {
    var view: SplashViewControllerProtocol? { get set }
    func viewDidAppear()
    func fetchProfile(token: String)
}

final class SplashPresenter: SplashPresenterProtocol {
    weak var view: SplashViewControllerProtocol?
    private let oAuth2TokenStorage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
    
    func viewDidAppear() {
        if oAuth2TokenStorage.token != nil {
            fetchProfile(token: oAuth2TokenStorage.token ?? "")
        } else {
            view?.showAuthViewController()
        }
    }
    
    func fetchProfile(token: String) {
        view?.showProgressHUD()
        profileService.fetchProfile(token) { [weak self] result in
            guard let self = self else { return }
            self.view?.hideProgressHUD()
            switch result {
            case .success:
                self.view?.switchToTabBarController()
                self.view?.fetchProfileImageURL(username: self.profileService.profile?.userName ?? "")
            case .failure(let error):
                self.view?.showAlert()
                print(error)
            }
        }
    }
}
