import UIKit

public protocol LoadingStateProvider {
	func showLoadingIndicator(title: String, message: String, over viewController: UIViewController)
	func hideLoadingIndicator(over viewController: UIViewController)

	/// Returns loading indicator view that can be embedded in the form. For example in `AutosubmitLine`
	var loadingIndicatorView: LoadingView { get }
}

public protocol LoadingView: UIView {
	func startAnimating()
	func stopAnimating()
}
