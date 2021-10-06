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
		
		view = webView
	}
	
	override func viewDidLoad() {
		self.presentationController?.delegate = self
		webView.load(URLRequest(url: url))
		webView.allowsBackForwardNavigationGestures = false
	}
}
