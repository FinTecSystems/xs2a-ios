import UIKit

/// Extension for quickly generating lighter/darker colors for a given UIColor
/// From Stackoverflow Answer: https://stackoverflow.com/a/63003757
/// By User Mojtaba Hosseini https://stackoverflow.com/users/5623035/mojtaba-hosseini
extension UIColor {
	func mix(with color: UIColor, amount: CGFloat) -> Self {
		var red1: CGFloat = 0
		var green1: CGFloat = 0
		var blue1: CGFloat = 0
		var alpha1: CGFloat = 0

		var red2: CGFloat = 0
		var green2: CGFloat = 0
		var blue2: CGFloat = 0
		var alpha2: CGFloat = 0

		getRed(&red1, green: &green1, blue: &blue1, alpha: &alpha1)
		color.getRed(&red2, green: &green2, blue: &blue2, alpha: &alpha2)

		return Self(
			red: red1 * CGFloat(1.0 - amount) + red2 * amount,
			green: green1 * CGFloat(1.0 - amount) + green2 * amount,
			blue: blue1 * CGFloat(1.0 - amount) + blue2 * amount,
			alpha: alpha1
		)
	}

	func lighter(by amount: CGFloat = 0.2) -> Self { mix(with: .white, amount: amount) }
	func darker(by amount: CGFloat = 0.2) -> Self { mix(with: .black, amount: amount) }
}

extension UIColor {
    /// Initialize with hex string; uses fallback color if invalid
    public convenience init(hex: String, defaultAlpha: CGFloat = 1.0, fallback: UIColor = .clear) {
        let hexStr = hex.trimmingCharacters(in: .whitespacesAndNewlines)
                        .replacingOccurrences(of: "#", with: "")
        var int: UInt64 = 0
        guard Scanner(string: hexStr).scanHexInt64(&int) else {
            var rF: CGFloat = 0, gF: CGFloat = 0, bF: CGFloat = 0, aF: CGFloat = 0
            fallback.getRed(&rF, green: &gF, blue: &bF, alpha: &aF)
            self.init(red: rF, green: gF, blue: bF, alpha: aF)
            return
        }
        let r, g, b, a: CGFloat
        switch hexStr.count {
        case 6:
            r = CGFloat((int >> 16) & 0xFF)/255
            g = CGFloat((int >> 8)  & 0xFF)/255
            b = CGFloat(int         & 0xFF)/255
            a = defaultAlpha
        case 8:
            a = CGFloat((int >> 24) & 0xFF)/255
            r = CGFloat((int >> 16) & 0xFF)/255
            g = CGFloat((int >> 8)  & 0xFF)/255
            b = CGFloat(int         & 0xFF)/255
        default:
            var rF: CGFloat = 0, gF: CGFloat = 0, bF: CGFloat = 0, aF: CGFloat = 0
            fallback.getRed(&rF, green: &gF, blue: &bF, alpha: &aF)
            self.init(red: rF, green: gF, blue: bF, alpha: aF)
            return
        }
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}
