import UIKit
import SafariServices

enum Severity: String {
	case none
	case info
	case warning
	case error
}

class ParagraphLine: UIViewController, FormLine, OpenLinkDelegate {
	var actionDelegate: ActionDelegate?
	
	private var severity: Severity
	private let paragraphTitle: String
	private let paragraphText: String
	
	let multiFormName: String?
	let multiFormValue: String?

	private let titleLabel = UILabel.makeInteractive()
	private let textLabel = UILabel.makeInteractive()

	/**
	 - Parameters:
	   - title: The title of this paragraph
	   - text: The text of this paragraph
	   - severity: The severity of this paragraph
	   - multiFormName: The name of the multi form this element is part of (if any)
	   - multiFormValue: The value of the sub form this element is part of (if any)
	*/
	init(title: String, text: String, severity: Severity, multiFormName: String?, multiFormValue: String?) {
		self.paragraphTitle = title
		self.paragraphText = text
		self.severity = severity
		self.multiFormName = multiFormName
		self.multiFormValue = multiFormValue

		titleLabel.numberOfLines = 0
		titleLabel.adjustsFontSizeToFitWidth = true
		titleLabel.font = XS2AiOS.shared.styleProvider.font.getFont(ofSize: 16, ofWeight: .traitBold)

		textLabel.numberOfLines = 0
		textLabel.font = XS2AiOS.shared.styleProvider.font.getFont(ofSize: 13, ofWeight: nil)
		textLabel.adjustsFontSizeToFitWidth = true

		super.init(nibName: nil, bundle: nil)
	}
	
	/// Function for opening webview in case the paragraph contains a tappable link
	func openLink(url: URL) {
		if UIApplication.shared.canOpenURL(url) == true {
			let config = SFSafariViewController.Configuration()
			config.barCollapsingEnabled = false
			config.entersReaderIfAvailable = true
			let safariVC = SFSafariViewController(url: url, configuration: config)
			self.present(safariVC, animated: true, completion: nil)
		}
	}
	
	/// Function for opening alert in case the paragraph contains a tappable notice
	func openAlert(content: String) {
		actionDelegate?.openAlert(content: content)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		/// Style the paragraph according to its severity
		switch severity {
		case .error:
			self.view.backgroundColor = XS2AiOS.shared.styleProvider.errorStyle.backgroundColor
			self.textLabel.textColor = XS2AiOS.shared.styleProvider.errorStyle.textColor
			self.titleLabel.textColor = XS2AiOS.shared.styleProvider.errorStyle.textColor
		case .info:
			self.view.backgroundColor = XS2AiOS.shared.styleProvider.infoStyle.backgroundColor
			self.textLabel.textColor = XS2AiOS.shared.styleProvider.infoStyle.textColor
			self.titleLabel.textColor = XS2AiOS.shared.styleProvider.infoStyle.textColor
		case .warning:
			self.view.backgroundColor = XS2AiOS.shared.styleProvider.warningStyle.backgroundColor
			self.textLabel.textColor = XS2AiOS.shared.styleProvider.warningStyle.textColor
			self.titleLabel.textColor = XS2AiOS.shared.styleProvider.warningStyle.textColor
		default:
			self.view.backgroundColor = XS2AiOS.shared.styleProvider.backgroundColor
		}
		
		/// We assign the texts for the labels here, because constructLabelString assigns colors to parts of the strings
		/// which will otherwise get overriden
		if paragraphTitle.count > 0 {
			titleLabel.attributedText = constructLabelString(stringToTest: self.paragraphTitle.trimmingCharacters(in: .whitespacesAndNewlines))
			titleLabel.isUserInteractionEnabled = true
		}
		
		if paragraphText.count > 0 {
			textLabel.attributedText = constructLabelString(stringToTest: self.paragraphText.trimmingCharacters(in: .whitespacesAndNewlines))
			titleLabel.isUserInteractionEnabled = true
		}
		
		self.view.layer.cornerRadius = XS2AiOS.shared.styleProvider.alertBorderRadius
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		titleLabel.openLinkDelegate = self
		textLabel.translatesAutoresizingMaskIntoConstraints = false
		textLabel.openLinkDelegate = self


		var subviewsToAdd: [UIView] = []
		
		if titleLabel.attributedText?.length ?? 0 > 0 {
			subviewsToAdd.append(titleLabel)
		}
		
		if textLabel.attributedText?.length ?? 0 > 0 {
			subviewsToAdd.append(textLabel)
		}

		let stackView = UIStackView(arrangedSubviews: subviewsToAdd)
		stackView.axis = .vertical
		stackView.distribution = .fill
		stackView.translatesAutoresizingMaskIntoConstraints = false

		view.addSubview(stackView)
		
		if severity == .error || severity == .warning || severity == .info {
			/// Add padding for the backgrounds in case there is a severity set
			stackView.layoutMargins = UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)
			stackView.isLayoutMarginsRelativeArrangement = true
		}

		NSLayoutConstraint.activate([
			stackView.topAnchor.constraint(equalTo: self.view.topAnchor),
			stackView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
			stackView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
			view.heightAnchor.constraint(equalTo: stackView.heightAnchor)
		])
	}
}
