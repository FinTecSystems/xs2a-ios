import UIKit

class RadioButtonController {
	let tickedRadioImage = UIImage(named: "radio_ticked", in: .images, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
	let radioImage = UIImage(named: "radio", in: .images, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)

	var buttonsArray: [RadioButton] = [] {
		didSet {
			for b in buttonsArray {
				b.setImage(radioImage, for: .normal)
				b.setImage(tickedRadioImage, for: .selected)
				b.tintColor = XS2A.shared.styleProvider.tintColor
			}
		}
	}
	var selectedButton: RadioButton?
	var defaultButton: RadioButton = RadioButton() {
		didSet {
			setSelectedButton(buttonSelected: self.defaultButton)
		}
	}

	func setSelectedButton(buttonSelected: RadioButton) {
		for b in buttonsArray {
			if b == buttonSelected {
				selectedButton = b
				b.isSelected = true
				triggerHapticFeedback(style: .light)
			} else {
				b.isSelected = false
			}
		}
	}
}
