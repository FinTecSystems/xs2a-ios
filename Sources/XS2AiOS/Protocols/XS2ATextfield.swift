import UIKit
class XS2ATextfield: UITextField {
	var parentDelegate: TextfieldParentDelegate?

	func styleTextfield(style: TextFieldStyles) {
		switch style {
		case .error:
			self.layer.borderWidth = XS2AiOS.shared.styleProvider.inputBorderWidthActive
			self.layer.borderColor = XS2AiOS.shared.styleProvider.errorStyle.backgroundColor.cgColor
			self.layer.add(getBorderWidthAnimation(type: .didStart), forKey: "Width")
		case .normal:
			if self.layer.borderWidth != XS2AiOS.shared.styleProvider.inputBorderWidth {
				self.layer.borderWidth = XS2AiOS.shared.styleProvider.inputBorderWidth
				self.layer.add(getBorderWidthAnimation(type: .didEnd), forKey: "Width")
			}
			self.layer.borderColor = XS2AiOS.shared.styleProvider.inputBorderColor.cgColor
		}
	}
	
	func styleDisabledState() {
		UIView.animate(withDuration: 0.1, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 1, options: .curveEaseOut) {
			self.backgroundColor = self.backgroundColor?.darker()
		}
	}
}
