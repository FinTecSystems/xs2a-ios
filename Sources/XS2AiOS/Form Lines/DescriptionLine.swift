import UIKit

class DescriptionLine: UIViewController, FormLine, OpenLinkDelegate {
	var actionDelegate: ActionDelegate?
	
	private let label = UILabel.makeInteractive()

	/**
	 - Parameters:
	   - text: The text for the description
	*/
	init(text: String) {
		self.label.attributedText = constructLabelString(stringToTest: text.trimmingCharacters(in: .whitespacesAndNewlines))
		self.label.numberOfLines = 0
		self.label.adjustsFontSizeToFitWidth = true
		self.label.isUserInteractionEnabled = true

		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func getQueryStringParameter(url: URL) -> URLComponents? {
		return URLComponents(url: url, resolvingAgainstBaseURL: true)
	}
	
	/// Function for opening webview or trigger autosubmit in case the paragraph contains a tappable link
	func openLink(url: URL) {
		actionDelegate?.openLink(url: url)
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
