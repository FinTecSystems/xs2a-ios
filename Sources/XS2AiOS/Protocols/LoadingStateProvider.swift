import UIKit

public protocol LoadingStateProvider {
    func showLoadingIndicator(title: String, message: String, over viewController: UIViewController)
    func hideLoadingIndicator(over viewController: UIViewController)
}
