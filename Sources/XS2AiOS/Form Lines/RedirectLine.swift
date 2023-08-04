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

	private let button: UIButton
	
	private let validAppRedirectionUrls = [
		"https://myaccount.ing.com/granting"
	]
	
	/**
	 - Parameters:
	   - label: The button text of this redirect line
	   - url: The URL to be opened when the button is tapped
	*/
	init(label: String, url: String) {
		button = UIButton.make(buttonType: .redirect)
		button.setTitle(label, for: .normal)

		self.url = url

		super.init(nibName: nil, bundle: nil)
		
		/// Attach buttonTapped function to the button
		button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
	}
	
	/*
	 Method that checks whether the redirect URL is in
	 a list of supported URLs that have a dedicated app-to-app
	 authentication flow.
	 */
	private func urlSupportsAppFlow() -> Bool {
		var supportsAppFlow = false

		for redirectionUrl in validAppRedirectionUrls {
			if (self.url.contains(redirectionUrl)) {
				supportsAppFlow = true
				break
			}
		}
		
		return supportsAppFlow
	}
	
	private func openInWebView() {
		guard let urlToOpen = URL(string: url) else {
			return
		}

		let webview = WebViewController(url: urlToOpen)
		webview.redirectActionDelegate = self
		
		/// We wrap the webview in a navigation controller so we can use its navigation bar for displaying the URL
		let navigationController = UINavigationController(rootViewController: webview)
		self.present(navigationController, animated: true, completion: nil)
	}
	
	private func openInAppOrSystemBrowser() {
		guard let urlToOpen = URL(string: url) else {
			return
		}
		
		UIApplication.shared.open(urlToOpen, options: [:], completionHandler: nil)
	}
	
	@objc func buttonTapped() {
		/// If the keyboard is still open, close it
		view.superview?.endEditing(true)

		triggerHapticFeedback(style: .light)
		
		if (urlSupportsAppFlow()) {
			showAppOrBrowserDialog(
				decidedForBrowserCallback: openInWebView,
				decidedForAppCallback: openInAppOrSystemBrowser
			)
		} else {
			openInWebView()
		}
	}
	
	private func showAppOrBrowserDialog(
		decidedForBrowserCallback: @escaping () -> Void,
		decidedForAppCallback: @escaping () -> Void
	) {
		let alert = UIAlertController(
			title: "Authentifizierungs-Methode wählen",
			message: "Wie möchtest du dich einloggen? Hast du die App deiner Bank installiert, wähle \"Banking App\", andernfalls \"Webseite\".",
			preferredStyle: .alert
		)
		
		alert.addAction(
			UIAlertAction(
				title: "Webseite",
				style: .default,
				handler: { action in
					decidedForBrowserCallback()
				}
			)
		)
		
		alert.addAction(
			UIAlertAction(
				title: "Banking App",
				style: .default,
				handler: { action in
					decidedForAppCallback()
				}
			)
		)
		
		self.present(alert, animated: true, completion: nil)
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

