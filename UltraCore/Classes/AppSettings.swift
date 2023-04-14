import UIKit

open class AppSettings {
    public init() {
        // реализация инициализатора
    }
    
    public var version: String = "0.0.1"
}


public func showSignUp(view controller: UIViewController) {
    SignUpWireframe.init(presentation: controller)
}
