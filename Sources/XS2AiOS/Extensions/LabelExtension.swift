import UIKit

enum LabelSize {
	case small
	case large
}

extension UILabel {
	static func make(size: LabelSize) -> UILabel {
		let label = UILabel()
		label.numberOfLines = 0
		label.adjustsFontSizeToFitWidth = true
		label.textColor = XS2AiOS.shared.styleProvider.textColor
		label.contentMode = .bottom
		switch size {
		case .small:
			label.font = XS2AiOS.shared.styleProvider.font.getFont(ofSize: 12, ofWeight: nil)
		case .large:
			label.font = XS2AiOS.shared.styleProvider.font.getFont(ofSize: 16, ofWeight: .traitBold)
		}

		return label
	}
	
	static func makeInteractive() -> InteractiveLinkLabel {
		let label = InteractiveLinkLabel()
		label.numberOfLines = 0
		label.adjustsFontSizeToFitWidth = true
		label.textColor = XS2AiOS.shared.styleProvider.textColor
		label.font = XS2AiOS.shared.styleProvider.font.getFont(ofSize: 14, ofWeight: nil)
		return label
	}
}
