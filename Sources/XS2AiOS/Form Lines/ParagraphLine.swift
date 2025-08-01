import UIKit

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
	internal let paragraphText: String

	private let titleLabel = UILabel.makeInteractive()
	private let textLabel = UILabel.makeInteractive()

	/**
	 - Parameters:
	   - title: The title of this paragraph
	   - text: The text of this paragraph
	   - severity: The severity of this paragraph
	*/
	init(title: String, text: String, severity: Severity) {
		self.paragraphTitle = title
        self.paragraphText = text
		self.severity = severity

		titleLabel.numberOfLines = 0
		titleLabel.adjustsFontSizeToFitWidth = true
		titleLabel.font = XS2A.shared.styleProvider.font.getFont(ofSize: 16, ofWeight: .traitBold)

		textLabel.numberOfLines = 0
		textLabel.font = XS2A.shared.styleProvider.font.getFont(ofSize: 13, ofWeight: nil)
		textLabel.adjustsFontSizeToFitWidth = true

		super.init(nibName: nil, bundle: nil)
	}
    
    func isError() -> Bool {
        return severity == .error
    }
	
	/// Function for opening webview in case the paragraph contains a tappable link
	func openLink(url: URL) {
		actionDelegate?.openLink(url: url)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		/// Style the paragraph according to its severity
		switch severity {
		case .error:
			self.view.backgroundColor = XS2A.shared.styleProvider.errorStyle.backgroundColor
			self.textLabel.textColor = XS2A.shared.styleProvider.errorStyle.textColor
			self.titleLabel.textColor = XS2A.shared.styleProvider.errorStyle.textColor
		case .info:
			self.view.backgroundColor = XS2A.shared.styleProvider.infoStyle.backgroundColor
			self.textLabel.textColor = XS2A.shared.styleProvider.infoStyle.textColor
			self.titleLabel.textColor = XS2A.shared.styleProvider.infoStyle.textColor
		case .warning:
			self.view.backgroundColor = XS2A.shared.styleProvider.warningStyle.backgroundColor
			self.textLabel.textColor = XS2A.shared.styleProvider.warningStyle.textColor
			self.titleLabel.textColor = XS2A.shared.styleProvider.warningStyle.textColor
		default:
			self.view.backgroundColor = XS2A.shared.styleProvider.backgroundColor
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
		
		self.view.layer.cornerRadius = XS2A.shared.styleProvider.alertBorderRadius
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
        
        setupAccessibility()
	}
    
    private func setupAccessibility() {
        titleLabel.isAccessibilityElement = false
        textLabel.isAccessibilityElement = false
        view.isAccessibilityElement = true
        view.accessibilityTraits = .staticText
        
        var serverityString = ""
        switch severity {
        case .warning:
            serverityString = getStringForKey(key: "ParagraphLine.Warning")
        case .info:
            serverityString = getStringForKey(key: "ParagraphLine.Info")
        case .error:
            serverityString = getStringForKey(key: "ParagraphLine.Error")
        case .none:
            serverityString = ""
        }
     
        view.accessibilityLabel = "\(constructLabelString(stringToTest: paragraphTitle).string). \(constructLabelString(stringToTest: paragraphText).string). \(serverityString)"
    }
}
