import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    
    private let keychainWrapper = KeychainWrapper.standard
    
    private enum Keys: String {
        case bearerToken
    }
    
    var token: String? {
        get { keychainWrapper.string(forKey: Keys.bearerToken.rawValue) }
        set {
            if let newValue {
                keychainWrapper.set(newValue, forKey: Keys.bearerToken.rawValue)
            } else {
                keychainWrapper.removeObject(forKey: Keys.bearerToken.rawValue)
            }
        }
    }
}

