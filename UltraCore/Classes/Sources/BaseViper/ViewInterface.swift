import UIKit

protocol ViewInterface: AnyObject {
    func show(error description: String)
}

extension ViewInterface {
    func show(error description: String) {
        let alertController = UIAlertController(title: "Ошибка", message: description, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        if let topController = UIApplication.shared.keyWindow?.rootViewController {
            topController.present(alertController, animated: true, completion: nil)
        }
    }
}
