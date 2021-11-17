import UIKit

enum RedirectActionTypes {
	case done
	case abort
}

protocol WebViewNotificationDelegate {
	func sendAction(redirectActionType: RedirectActionTypes)
}

class RedirectLine: UIViewController, FormLine, WebViewNotificationDelegate {
	var actionDelegate: ActionDelegate?
	
	private let url: String
	
	let multiFormName: String?
	let multiFormValue: String?

	private let button: UIButton
	
	/**
	 - Parameters:
	   - label: The button text of this redirect line
	   - url: The URL to be opened when the button is tapped
	   - multiFormName: The name of the multi form this element is part of (if any)
	   - multiFormValue: The value of the sub form this element is part of (if any)
	*/
	init(label: String, url: String, multiFormName: String?, multiFormValue: String?) {
		button = UIButton.make(buttonType: .redirect)
		button.setTitle(label, for: .normal)

		self.multiFormName = multiFormName
		self.multiFormValue = multiFormValue
		self.url = url

		super.init(nibName: nil, bundle: nil)
		
		/// Attach buttonTapped function to the button
		button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
	}
	
	@objc func buttonTapped() {
		guard let urlToOpen = URL(string: url) else {
			return
		}

		/// If the keyboard is still open, close it
		view.superview?.endEditing(true)

		triggerHapticFeedback(style: .light)
		
		let webview = WebViewController(url: urlToOpen)
		webview.redirectActionDelegate = self
		
		/// We wrap the webview in a navigation controller so we can use its navigation bar for displaying the URL
		let navigationController = UINavigationController(rootViewController: webview)
		self.present(navigationController, animated: true, completion: nil)
	}
	
	func sendAction(redirectActionType: RedirectActionTypes) {
		actionDelegate?.sendAction(actionType: .redirect, withLoadingIndicator: true, additionalPayload: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()

		view.addSubview(button)

		NSLayoutConstraint.activate([
			view.heightAnchor.constraint(equalTo: button.heightAnchor),
			button.widthAnchor.constraint(equalTo: view.widthAnchor),
		])
	}
}

