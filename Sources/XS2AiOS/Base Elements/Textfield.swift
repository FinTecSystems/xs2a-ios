import UIKit

enum TextFieldStyles {
	case error
	case normal
}

class Textfield: XS2ATextfield, UITextFieldDelegate {
	let insets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 15)

	func setupStyling() {
		self.clipsToBounds = true
		self.tintColor = XS2AiOS.shared.styleProvider.tintColor
		self.backgroundColor = XS2AiOS.shared.styleProvider.inputBackgroundColor
		self.layer.cornerRadius = XS2AiOS.shared.styleProvider.inputBorderRadius
		self.layer.borderWidth = XS2AiOS.shared.styleProvider.inputBorderWidth
		self.layer.borderColor = XS2AiOS.shared.styleProvider.inputBorderColor.cgColor
		self.font = XS2AiOS.shared.styleProvider.font.getFont(ofSize: 20, ofWeight: nil)
		self.textColor = XS2AiOS.shared.styleProvider.inputTextColor
		self.heightAnchor.constraint(equalToConstant: 50).isActive = true
	}
	
	override open func textRect(forBounds bounds: CGRect) -> CGRect {
		return bounds.inset(by: insets)
	}

	override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
		return bounds.inset(by: insets)
	}

	override open func editingRect(forBounds bounds: CGRect) -> CGRect {
		return bounds.inset(by: insets)
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		let shouldReturn = parentDelegate?.textFieldShouldReturn(textField)
		
		return shouldReturn ?? false
	}

	
	override init(frame: CGRect) {
		super.init(frame: frame)
		delegate = self
		setupStyling()
	}

	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)!
		delegate = self
		setupStyling()
	}
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		if self.layer.borderWidth != XS2AiOS.shared.styleProvider.inputBorderWidthActive ||
			self.layer.borderColor != XS2AiOS.shared.styleProvider.tintColor.cgColor {
			self.layer.borderColor = XS2AiOS.shared.styleProvider.tintColor.cgColor
			self.layer.borderWidth = XS2AiOS.shared.styleProvider.inputBorderWidthActive
			self.layer.add(getBorderAnimation(type: .didStart), forKey: "Border")
		}
	}
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		self.layer.borderWidth = XS2AiOS.shared.styleProvider.inputBorderWidth
		self.layer.borderColor = XS2AiOS.shared.styleProvider.inputBorderColor.cgColor
		self.layer.add(getBorderAnimation(type: .didEnd), forKey: "Border")
	}
	
	func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
		return parentDelegate?.shouldBeginEditing() ?? true
	}
}
