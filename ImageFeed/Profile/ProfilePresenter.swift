import Foundation
import WebKit

public protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    private var profileImageServiceObserver: NSObjectProtocol?
    let profile = ProfileService.shared.profile
    
    func viewDidLoad() {
        guard let avatarURL = ProfileImageService.shared.avatarURL,
              let url = URL(string: avatarURL)
        else { return }
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: SplashViewController.DidChangeNotification,
                object: nil,
                queue: .main
            ) {[weak self] _ in
                guard let self = self else { return }
                self.view?.updateAvatar(url: url)
            }
        view?.updateAvatar(url: url)
        loadProfile()
    }
    
    static func cleanCookiesAndToken() {
        OAuth2TokenStorage().token = nil
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    private func loadProfile() {
        guard let profile = profile else { return }
        view?.updateProfileDetails(name: profile.name,
                                   login: profile.loginName,
                                   bio: profile.bio)
    }
}
