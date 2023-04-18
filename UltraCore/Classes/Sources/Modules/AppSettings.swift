import UIKit
import PodAsset

open class AppSettings {
    static let shared = AppSettings()
    public var version: String = "0.0.1"
    lazy var podAsset = PodAsset.bundle(forPod: "UltraCore")
}


public func showSignUp(view controller: UIViewController) {
    SignUpWireframe.init(presentation: controller)
}
