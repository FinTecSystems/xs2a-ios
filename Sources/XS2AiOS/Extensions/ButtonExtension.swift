import UIKit

enum XS2AButtonType {
	case submit
	case autosubmit
	case linkAutosubmit
	case back
	case abort
	case restart
	case redirect
	case notify
	case switch_login_tabs
	case none
}

extension UIButton {
	static func make(buttonType: XS2AButtonType) -> UIButton {
		let button = UIButton()

		let style: XS2AiOS.ButtonStyle
		switch buttonType {
		case .abort:
			style = XS2AiOS.shared.styleProvider.abortButtonStyle
		case .back:
			style = XS2AiOS.shared.styleProvider.backButtonStyle
		case .restart:
			style = XS2AiOS.shared.styleProvider.restartButtonStyle
		default:
			style = XS2AiOS.shared.styleProvider.submitButtonStyle
		}

		button.setTitleColor(style.textColor, for: .normal)
		button.setBackgroundColor(color: style.backgroundColor, forState: .normal)
		button.setBackgroundColor(color: style.backgroundColor.lighter(), forState: .highlighted)

		button.layer.cornerRadius = XS2AiOS.shared.styleProvider.buttonBorderRadius
		button.layer.borderWidth = style.borderWidth
		button.layer.borderColor = style.borderColor.cgColor

		button.translatesAutoresizingMaskIntoConstraints = false
		button.titleLabel?.font = XS2AiOS.shared.styleProvider.font.getFont(ofSize: 18, ofWeight: .traitBold)
		button.heightAnchor.constraint(equalToConstant: 50).isActive = true

		return button
	}
	
	func setBackgroundColor(color: UIColor, forState: UIControl.State) {
		let minimumSize: CGSize = CGSize(width: 1.0, height: 1.0)

		UIGraphicsBeginImageContext(minimumSize)

		if let context = UIGraphicsGetCurrentContext() {
			context.setFillColor(color.cgColor)
			context.fill(CGRect(origin: .zero, size: minimumSize))
		}

		let colorImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()

		self.clipsToBounds = true
		self.setBackgroundImage(colorImage, for: forState)
	}
}
