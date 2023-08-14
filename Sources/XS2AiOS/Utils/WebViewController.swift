import WebKit

/// WebView Wrapper Class
/// Used for showing webviews in case of redirect based flows
class WebViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler, UIAdaptivePresentationControllerDelegate {
	
	/// Delegate for notifying the constructing parent class of the next action to take
	var redirectActionDelegate: WebViewNotificationDelegate?
	
	/// The web view
	var webView: WKWebView!
	
	/// The URL to load
	let url: URL
	
	/// Function for handling JS-to-native callbacks from the page being loaded
	func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
		guard let response = message.body as? String else { return }
		
		if (response == "done") {
			dismiss(animated: true) {
				self.redirectActionDelegate?.sendAction(redirectActionType: .done)
			}
		} else {
			dismiss(animated: true) {
				self.redirectActionDelegate?.sendAction(redirectActionType: .abort)
			}
		}
	}
	
	init(url: URL) {
		self.url = url
		
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
		let contentController = WKUserContentController()
		/// Register the JS-to-native callbacks used above
		contentController.add(self, name: "callback")
		
		let config = WKWebViewConfiguration()
		config.userContentController = contentController
		
		let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
		webView = WKWebView(frame: frame, configuration: config)
		webView.navigationDelegate = self
		
		webView.addObserver(self, forKeyPath: "URL", options: .new, context: nil)

		/// Set the title for the wrapping navigation controller to display
		self.navigationItem.title = url.host

		let backButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(closeButtonPressed))
		self.navigationItem.leftBarButtonItem = backButton
		
		view = webView
	}
	
	/**
	 Function that checks when a redirect is received and if that redirect is to the provided redirectLink,
	 the redirect is aborted and the session advanced. This is for cases where a redirectLink is provided and the user
	 decided to use this in-app webview for authentication with the bank, where we after authentcation should just close
	 this view and advance the session.
	 */
	func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
		if (self.webView!.url?.absoluteString == XS2AiOS.shared.configuration.redirectDeepLink) {
			self.webView!.stopLoading()
			dismiss(animated: true) {
				self.redirectActionDelegate?.sendAction(redirectActionType: .done)
			}
		}
	}
	
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		if let key = change?[NSKeyValueChangeKey.newKey] {
			if let keyURL = URL(string: String(describing: key)) {
				self.navigationItem.title = keyURL.host
			}

		}
	}
	
	private func getSecureIcon(isSecure: Bool) -> UIBarButtonItem {
		let iconImage = UIImage(named: isSecure ? "lock" : "lock_slash", in: .images, compatibleWith: nil)
		
		let barButton = UIButton(type: .custom)
		barButton.frame = CGRect(x: 0.0, y: 0.0, width: 20, height: 20)
		barButton.setImage(iconImage, for: .normal)

		let barButtonItem = UIBarButtonItem(customView: barButton)
		
		if let barButtonItemCustomView = barButtonItem.customView {
			NSLayoutConstraint.activate([
				barButtonItemCustomView.widthAnchor.constraint(equalToConstant: 24),
				barButtonItemCustomView.heightAnchor.constraint(equalToConstant: 24)
			])
		}
		
		return barButtonItem
	}
	
	/// Function called after every navigation
	/// Checks for status of the loaded sites certificate and displays and lock icon depending on the status
	func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		if let serverTrust = self.webView.serverTrust {
			DispatchQueue.global().async {
				var isSecure = false

				if #available(iOS 13.0, *) {
					SecTrustEvaluateAsyncWithError(serverTrust, DispatchQueue.global()) {
						trust, result, error in

						if result {
							isSecure = true
						}
					}
				} else {
					var trustResult: SecTrustResultType = .invalid
					SecTrustEvaluate(serverTrust, &trustResult)

					if (trustResult == .proceed || trustResult == .unspecified) {
						isSecure = true
					}
				}
				
				/// Update UI to reflect security status
				DispatchQueue.main.async {
					self.navigationItem.rightBarButtonItem = self.getSecureIcon(isSecure: isSecure)
				}
			}
		} else {
			self.navigationItem.rightBarButtonItem = self.getSecureIcon(isSecure: false)
		}
	}

	@objc func closeButtonPressed() {
		self.dismiss(animated: true, completion: nil)
	}
	
	override func viewDidLoad() {
		self.presentationController?.delegate = self
		webView.load(URLRequest(url: url))
		webView.allowsBackForwardNavigationGestures = false
	}
}
