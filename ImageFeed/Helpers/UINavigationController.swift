import Foundation
import UIKit

class CustomNavigationController: UINavigationController {
    override open var childForStatusBarStyle: UIViewController? {
        return topViewController
    }
    
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? .default
    }
}
