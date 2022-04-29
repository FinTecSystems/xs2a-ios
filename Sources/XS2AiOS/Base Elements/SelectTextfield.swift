import UIKit

class SelectTextfield: UITextField, UITextFieldDelegate {
	let insets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 15)

	func setupStyling() {
		self.tintColor = .clear
		self.clipsToBounds = true
		self.tintColor = XS2AiOS.shared.styleProvider.tintColor
		self.backgroundColor = XS2AiOS.shared.styleProvider.inputBackgroundColor
		self.layer.cornerRadius = XS2AiOS.shared.styleProvider.inputBorderRadius
		self.font = XS2AiOS.shared.styleProvider.font.getFont(ofSize: 20, ofWeight: nil)
		self.textColor = XS2AiOS.shared.styleProvider.inputTextColor
		self.heightAnchor.constraint(equalToConstant: 50).isActive = true

		let background = UIImage(named: "select_chevrons", in: .images, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
		let imageView = UIImageView(image: background)

		imageView.tintColor = XS2AiOS.shared.styleProvider.placeholderColor
		self.rightViewMode = .always
		imageView.contentMode = .center
		self.rightView = imageView
	}
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		return false
	}
	
	override func caretRect(for position: UITextPosition) -> CGRect {
		return .zero
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
	
	override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
		return CGRect(x: bounds.width - 30, y: 0, width: 20 , height: bounds.height)
	}
	
	override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
		return CGRect(x: 10, y: 0, width: 20 , height: bounds.height)
	}
	
	func styleTextfield(style: TextFieldStyles) {
		switch style {
		case .error:
			self.layer.borderWidth = 2
			self.layer.borderColor = XS2AiOS.shared.styleProvider.errorStyle.backgroundColor.cgColor
			self.layer.add(getBorderWidthAnimation(type: .didStart), forKey: "Width")
		case .normal:
			if self.layer.borderWidth != 0 {
				self.layer.borderWidth = 0
				self.layer.add(getBorderWidthAnimation(type: .didEnd), forKey: "Width")
			}
		}
	}
	
	func styleDisabledState() {
		UIView.animate(withDuration: 0.1, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 1, options: .curveEaseOut) {
			self.backgroundColor = self.backgroundColor?.darker()
		}
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
		if self.layer.borderWidth != 2 {
			self.layer.borderWidth = 2
			self.layer.add(getBorderWidthAnimation(type: .didStart), forKey: "Width")
		}
		
		self.layer.borderColor = XS2AiOS.shared.styleProvider.tintColor.cgColor
		self.rightView?.tintColor = XS2AiOS.shared.styleProvider.tintColor
	}
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		if self.layer.borderWidth != 0 {
			self.layer.borderWidth = 0
			self.layer.add(getBorderWidthAnimation(type: .didEnd), forKey: "Width")
		}

		self.rightView?.tintColor = XS2AiOS.shared.styleProvider.placeholderColor
	}
	
	func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
		return true
	}
}
