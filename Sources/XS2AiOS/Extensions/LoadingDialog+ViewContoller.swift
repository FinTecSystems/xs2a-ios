import UIKit
import NVActivityIndicatorView

struct ProgressDialog {
	static var alert = UIAlertController()
	static var indicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50), type: .lineScale, color: XS2A.shared.styleProvider.tintColor)
}

extension UIViewController {
	func showLoadingIndicator(title: String = "", message: String = "") {
		XS2A.shared.loadingStateProvider.showLoadingIndicator(title: title, message: message, over: self)
	}

	func hideLoadingIndicator() {
		XS2A.shared.loadingStateProvider.hideLoadingIndicator(over: self)
	}
}

class XS2ALoadingStateProvider: LoadingStateProvider {
	var loadingIndicatorView: LoadingView {
		NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50), type: .lineScale, color: XS2A.shared.styleProvider.tintColor)
	}

	func showLoadingIndicator(title: String, message: String, over viewController: UIViewController) {
		ProgressDialog.alert = UIAlertController(title: title.isEmpty ? nil : title, message: message, preferredStyle: .alert)
		
		if (!title.isEmpty) {
			ProgressDialog.alert.setValue(
				NSAttributedString(
					string: title,
					attributes: [
						NSAttributedString.Key.font: XS2A.shared.styleProvider.font.getFont(ofSize: 15, ofWeight: .traitBold),
						NSAttributedString.Key.foregroundColor: XS2A.shared.styleProvider.textColor
					]
				),
				forKey: "attributedTitle"
			)
		}
		
		if (!message.isEmpty) {
			ProgressDialog.alert.setValue(
				NSAttributedString(
					string: message,
					attributes: [
						NSAttributedString.Key.font: XS2A.shared.styleProvider.font.getFont(ofSize: 14, ofWeight: nil),
						NSAttributedString.Key.foregroundColor: XS2A.shared.styleProvider.textColor
					]
				),
				forKey: "attributedMessage"
			)
		}
		
		ProgressDialog.alert.view.addSubview(ProgressDialog.indicatorView)
		
		let alertBackground = (ProgressDialog.alert.view.subviews.first?.subviews.first?.subviews.first!)! as UIView
		alertBackground.backgroundColor = XS2A.shared.styleProvider.backgroundColor

		ProgressDialog.indicatorView.translatesAutoresizingMaskIntoConstraints = false
		ProgressDialog.indicatorView.centerXAnchor.constraint(lessThanOrEqualTo: ProgressDialog.alert.view.centerXAnchor).isActive = true
		
		if (title.isEmpty && message.isEmpty) {
			NSLayoutConstraint.activate([
				ProgressDialog.indicatorView.centerYAnchor.constraint(lessThanOrEqualTo: ProgressDialog.alert.view.centerYAnchor),
				ProgressDialog.indicatorView.heightAnchor.constraint(equalTo: ProgressDialog.alert.view.heightAnchor, multiplier: 0.6),
				ProgressDialog.indicatorView.widthAnchor.constraint(equalTo: ProgressDialog.alert.view.widthAnchor, multiplier: 0.6),
			])
		} else {
			NSLayoutConstraint.activate([
				ProgressDialog.indicatorView.heightAnchor.constraint(equalToConstant: 40),
				ProgressDialog.indicatorView.widthAnchor.constraint(equalToConstant: 40),
				ProgressDialog.indicatorView.bottomAnchor.constraint(equalTo: ProgressDialog.alert.view.bottomAnchor, constant: -20),
			]);
		}
        
        let alertView = ProgressDialog.alert.view!
        alertView.isAccessibilityElement = true
        alertView.accessibilityViewIsModal = true
        alertView.accessibilityLabel = title.isEmpty ? getStringForKey(key: "LoadingDialog.Loading") : title
        alertView.accessibilityHint  = message.isEmpty ? getStringForKey(key: "LoadingDialog.PleaseWait") : message
		
		ProgressDialog.indicatorView.startAnimating()
        viewController.present(ProgressDialog.alert, animated: true) {
            UIAccessibility.post(
                notification: .screenChanged,
                argument: alertView
            )
        }
	}

	func hideLoadingIndicator(over viewController: UIViewController) {
		ProgressDialog.alert.dismiss(animated: true) {
			ProgressDialog.indicatorView.stopAnimating()
		}
	}
}

extension NVActivityIndicatorView: LoadingView {
}
