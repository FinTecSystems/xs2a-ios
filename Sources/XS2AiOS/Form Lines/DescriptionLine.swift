import UIKit
import SafariServices

class DescriptionLine: UIViewController, FormLine, OpenLinkDelegate {
	var actionDelegate: ActionDelegate?
	
	private let label = UILabel.makeInteractive()

	let multiFormName: String?
	let multiFormValue: String?

	/**
	 - Parameters:
	   - text: The text for the description
	   - multiFormName: The name of the multi form this element is part of (if any)
	   - multiFormValue: The value of the sub form this element is part of (if any)
	*/
	init(text: String, multiFormName: String?, multiFormValue: String?) {
		self.label.attributedText = constructLabelString(stringToTest: text.trimmingCharacters(in: .whitespacesAndNewlines))
		self.label.numberOfLines = 0
		self.label.adjustsFontSizeToFitWidth = true
		self.label.isUserInteractionEnabled = true
		
		self.multiFormName = multiFormName
		self.multiFormValue = multiFormValue
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func openAlert(content: String) {
		actionDelegate?.openAlert(content: content)
	}
	
	func getQueryStringParameter(url: URL) -> URLComponents? {
		return URLComponents(url: url, resolvingAgainstBaseURL: true)
	}
	
	/// Function for opening webview or trigger autosubmit in case the paragraph contains a tappable link
	func openLink(url: URL) {
		let urlString = "\(url)"
		if urlString.starts(with: "autosubmit::") {
			/// Link carries an autosubmit with query parameters
			/// We build a fake URL to make use of Swift's URL class for getting the query parameters
			let fakeUrl = URL(string: "https://xs2a.com/?\(urlString.components(separatedBy: "::")[1])")
			guard let payload = fakeUrl?.queryDictionary else {
				return
			}

			actionDelegate?.sendAction(actionType: .linkAutosubmit, withLoadingIndicator: true, additionalPayload: payload)
		} else if UIApplication.shared.canOpenURL(url) == true {
			let config = SFSafariViewController.Configuration()
			config.barCollapsingEnabled = false
			config.entersReaderIfAvailable = true
			let safariVC = SFSafariViewController(url: url, configuration: config)
			self.present(safariVC, animated: true, completion: nil)
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		label.translatesAutoresizingMaskIntoConstraints = false
		label.openLinkDelegate = self
		view.addSubview(label)
		
		NSLayoutConstraint.activate([
			label.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			label.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			view.heightAnchor.constraint(equalTo: label.heightAnchor),
		])
	}
}
