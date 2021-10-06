import UIKit

public enum FontName {
	case custom(String)
	case systemDefault
}

class Font {
	let fontName: FontName
	
	private func getFallbackFont(ofSize: CGFloat, ofWeight: UIFontDescriptor.SymbolicTraits?) -> UIFont {
		let fallbackFont = UIFont.systemFont(ofSize: ofSize)
		
		if let ofWeight = ofWeight {
			if let descriptor = fallbackFont.fontDescriptor.withSymbolicTraits(ofWeight) {
				return UIFont(descriptor: descriptor, size: ofSize)
			}
		}

		return fallbackFont
	}
	
	func getFont(ofSize: CGFloat, ofWeight: UIFontDescriptor.SymbolicTraits?) -> UIFont {
		switch fontName {
		case .custom(let customFontName):
			if let customFont = UIFont(name: customFontName, size: ofSize) {
				if let ofWeight = ofWeight {
					guard let descriptor = customFont.fontDescriptor.withSymbolicTraits(ofWeight) else {
						return getFallbackFont(ofSize: ofSize, ofWeight: nil)
					}

					return UIFont(descriptor: descriptor, size: ofSize)
				} else {
					return customFont
				}
			}
			
			return getFallbackFont(ofSize: ofSize, ofWeight: ofWeight)
		case .systemDefault:
			return getFallbackFont(ofSize: ofSize, ofWeight: ofWeight)
		}
	}
	
	public init(fontName: FontName) {
		self.fontName = fontName
	}
}
