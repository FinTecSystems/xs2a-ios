import UIKit
import NVActivityIndicatorView

struct ProgressDialog {
	static var alert = UIAlertController()
	static var indicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50), type: .lineScale, color: XS2AiOS.shared.styleProvider.tintColor)
}

extension UIViewController {
	func showLoadingIndicator(){
		ProgressDialog.alert = UIAlertController(title: nil, message: "", preferredStyle: .alert)
		
		ProgressDialog.alert.view.addSubview(ProgressDialog.indicatorView)
		
		let alertBackground = (ProgressDialog.alert.view.subviews.first?.subviews.first?.subviews.first!)! as UIView
		alertBackground.backgroundColor = XS2AiOS.shared.styleProvider.backgroundColor

		ProgressDialog.indicatorView.translatesAutoresizingMaskIntoConstraints = false
		ProgressDialog.indicatorView.heightAnchor.constraint(equalTo: ProgressDialog.alert.view.heightAnchor, multiplier: 0.6).isActive = true
		ProgressDialog.indicatorView.widthAnchor.constraint(equalTo: ProgressDialog.alert.view.widthAnchor, multiplier: 0.6).isActive = true
		ProgressDialog.indicatorView.centerXAnchor.constraint(lessThanOrEqualTo: ProgressDialog.alert.view.centerXAnchor).isActive = true
		ProgressDialog.indicatorView.centerYAnchor.constraint(lessThanOrEqualTo: ProgressDialog.alert.view.centerYAnchor).isActive = true
		
		ProgressDialog.indicatorView.startAnimating()
		present(ProgressDialog.alert, animated: true, completion: nil)
	}

	func hideLoadingIndicator(){
		ProgressDialog.alert.dismiss(animated: true) {
			ProgressDialog.indicatorView.stopAnimating()
		}

	}
}
