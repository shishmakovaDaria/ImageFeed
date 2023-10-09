import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let scene = (scene as? UIWindowScene) else { return }
        let splashViewController = SplashViewController()
        let splashPresenter = SplashPresenter()
        splashViewController.presenter = splashPresenter
        splashPresenter.view = splashViewController
        
        window = UIWindow(windowScene: scene)
        window?.rootViewController = splashViewController
        window?.makeKeyAndVisible()
    }
}
