import UIKit

final class TrackerAlert {
    static func showAlert(on viewController: UIViewController, alertTitle: String, completion: @escaping (() -> Void)) {
        let deleteAction = UIAlertAction(title: Constants.delete, style: .destructive) { _ in
            completion()
        }
        
        let cancel = UIAlertAction(title: Constants.cancelAlert, style: .cancel)
        
        let alertController = UIAlertController(title: alertTitle, message: "", preferredStyle: .actionSheet)
        alertController.addAction(deleteAction)
        alertController.addAction(cancel)
        viewController.present(alertController, animated: true)
    }
}
