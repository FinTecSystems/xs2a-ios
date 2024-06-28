import UIKit

class TriggerTextfield: XS2ATextfield, UITextFieldDelegate {
	let insets = UIEdgeInsets(top: 0, left: 35, bottom: 0, right: 10)

	func setupStyling() {
		self.tintColor = .clear
		self.clipsToBounds = true
		self.tintColor = XS2A.shared.styleProvider.tintColor
		self.backgroundColor = XS2A.shared.styleProvider.inputBackgroundColor
		self.layer.cornerRadius = XS2A.shared.styleProvider.inputBorderRadius
		self.layer.borderWidth = XS2A.shared.styleProvider.inputBorderWidth
		self.layer.borderColor = XS2A.shared.styleProvider.inputBorderColor.cgColor
		self.font = XS2A.shared.styleProvider.font.getFont(ofSize: 20, ofWeight: nil)
		self.textColor = XS2A.shared.styleProvider.inputTextColor
		self.heightAnchor.constraint(equalToConstant: 50).isActive = true

		let background = UIImage(named: "glass", in: .images, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
		let imageView = UIImageView(image: background)

		imageView.tintColor = XS2A.shared.styleProvider.placeholderColor
		self.leftViewMode = .always
		imageView.contentMode = .center
		self.leftView = imageView
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

	override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
		return CGRect(x: 10, y: 0, width: 20 , height: bounds.height)
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
		if self.layer.borderWidth != XS2A.shared.styleProvider.inputBorderWidthActive ||
			self.layer.borderColor != XS2A.shared.styleProvider.tintColor.cgColor {
			self.layer.borderWidth = XS2A.shared.styleProvider.inputBorderWidthActive
			self.layer.add(getBorderAnimation(type: .didStart), forKey: "Border")
		}

		self.layer.borderWidth = XS2A.shared.styleProvider.inputBorderWidthActive
		self.layer.borderColor = XS2A.shared.styleProvider.tintColor.cgColor
		self.leftView?.tintColor = XS2A.shared.styleProvider.tintColor
	}
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		self.layer.borderWidth = XS2A.shared.styleProvider.inputBorderWidth
		self.layer.borderColor = XS2A.shared.styleProvider.inputBorderColor.cgColor
		self.layer.add(getBorderAnimation(type: .didEnd), forKey: "Border")
	}
	
	func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
		return parentDelegate?.shouldBeginEditing() ?? true
	}

}
