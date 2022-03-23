import UIKit
import NVActivityIndicatorView

struct ProgressDialog {
	static var alert = UIAlertController()
	static var indicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50), type: .lineScale, color: XS2AiOS.shared.styleProvider.tintColor)
}

extension UIViewController {
	func showLoadingIndicator(title: String = "", message: String = "") {
		ProgressDialog.alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		
		if (!title.isEmpty) {
			ProgressDialog.alert.setValue(
				NSAttributedString(
					string: title,
					attributes: [
						NSAttributedString.Key.font: XS2AiOS.shared.styleProvider.font.getFont(ofSize: 15, ofWeight: .traitBold),
						NSAttributedString.Key.foregroundColor: XS2AiOS.shared.styleProvider.textColor
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
						NSAttributedString.Key.font: XS2AiOS.shared.styleProvider.font.getFont(ofSize: 14, ofWeight: nil),
						NSAttributedString.Key.foregroundColor: XS2AiOS.shared.styleProvider.textColor
					]
				),
				forKey: "attributedMessage"
			)
		}
		
		ProgressDialog.alert.view.addSubview(ProgressDialog.indicatorView)
		
		let alertBackground = (ProgressDialog.alert.view.subviews.first?.subviews.first?.subviews.first!)! as UIView
		alertBackground.backgroundColor = XS2AiOS.shared.styleProvider.backgroundColor

		ProgressDialog.indicatorView.translatesAutoresizingMaskIntoConstraints = false
		ProgressDialog.indicatorView.centerXAnchor.constraint(lessThanOrEqualTo: ProgressDialog.alert.view.centerXAnchor).isActive = true
		
		if (title.isEmpty && message.isEmpty) {
			ProgressDialog.indicatorView.centerYAnchor.constraint(lessThanOrEqualTo: ProgressDialog.alert.view.centerYAnchor).isActive = true
			ProgressDialog.indicatorView.heightAnchor.constraint(equalTo: ProgressDialog.alert.view.heightAnchor, multiplier: 0.6).isActive = true
			ProgressDialog.indicatorView.widthAnchor.constraint(equalTo: ProgressDialog.alert.view.widthAnchor, multiplier: 0.6).isActive = true
		} else {
			ProgressDialog.indicatorView.heightAnchor.constraint(equalToConstant: 40).isActive = true
			ProgressDialog.indicatorView.widthAnchor.constraint(equalToConstant: 40).isActive = true
			ProgressDialog.indicatorView.bottomAnchor.constraint(equalTo: ProgressDialog.alert.view.bottomAnchor, constant: -20).isActive = true
		}
		
		ProgressDialog.indicatorView.startAnimating()
		present(ProgressDialog.alert, animated: true, completion: nil)
	}

	func hideLoadingIndicator(){
		ProgressDialog.alert.dismiss(animated: true) {
			ProgressDialog.indicatorView.stopAnimating()
		}

	}
}
