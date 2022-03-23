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
		
		switch buttonType {
		case .abort:
			button.setTitleColor(XS2AiOS.shared.styleProvider.abortButtonStyle.textColor, for: .normal)
			button.setBackgroundColor(color: XS2AiOS.shared.styleProvider.abortButtonStyle.backgroundColor, forState: .normal)
			button.setBackgroundColor(color: XS2AiOS.shared.styleProvider.abortButtonStyle.backgroundColor.lighter(), forState: .highlighted)
		case .back:
			button.setTitleColor(XS2AiOS.shared.styleProvider.backButtonStyle.textColor, for: .normal)
			button.setBackgroundColor(color: XS2AiOS.shared.styleProvider.backButtonStyle.backgroundColor, forState: .normal)
			button.setBackgroundColor(color: XS2AiOS.shared.styleProvider.backButtonStyle.backgroundColor.lighter(), forState: .highlighted)
		case .restart:
			button.setTitleColor(XS2AiOS.shared.styleProvider.restartButtonStyle.textColor, for: .normal)
			button.setBackgroundColor(color: XS2AiOS.shared.styleProvider.restartButtonStyle.backgroundColor, forState: .normal)
			button.setBackgroundColor(color: XS2AiOS.shared.styleProvider.restartButtonStyle.backgroundColor.lighter(), forState: .highlighted)
		default:
			button.setTitleColor(XS2AiOS.shared.styleProvider.submitButtonStyle.textColor, for: .normal)
			button.setBackgroundColor(color: XS2AiOS.shared.styleProvider.submitButtonStyle.backgroundColor, forState: .normal)
			button.setBackgroundColor(color: XS2AiOS.shared.styleProvider.submitButtonStyle.backgroundColor.lighter(), forState: .highlighted)
		}

		button.layer.cornerRadius = XS2AiOS.shared.styleProvider.buttonBorderRadius
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
