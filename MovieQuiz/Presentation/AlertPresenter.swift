import UIKit
class AlertPresenter {
    private weak var presentingViewController: UIViewController?
    init(presentingViewController: UIViewController) {
        self.presentingViewController = presentingViewController
    }
    func presentAlert(with model: AlertModel) {
        let alert = UIAlertController(title: model.title,
                                      message: model.message,
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: model.buttonText,
                                   style: .default) { _ in
            model.completion?()
        }
        alert.addAction(action)
        presentingViewController?.present(alert, animated: true, completion: nil)
    }
}
