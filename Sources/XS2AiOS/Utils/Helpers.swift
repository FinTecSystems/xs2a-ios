import UIKit

func triggerHapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle) {
	let generator = UIImpactFeedbackGenerator(style: style)
	generator.impactOccurred()
}

func getRegexMatches(for regex: String, in text: String) -> [NSRange] {
	do {
		let regex = try NSRegularExpression(pattern: regex)
		let results = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
		return results.map {( $0.range )}
	} catch let error {
		print("invalid regex: \(error.localizedDescription)")
		return []
	}
}

/// Check if iban starts like an iban, two alphabetic chars and then two digits
func stringStartsAsIban(stringToTest: String) -> Bool {
	let matches = getRegexMatches(for: #"^[a-zA-Z]{2}[0-9]{2}"#, in: stringToTest)

	return matches.count > 0
}

/// Check if string contains a valid IBAN
func stringContainsValidIban(stringToTest: String) -> Bool {
	let matches = getRegexMatches(for: #"[A-Z]{2}\d{2}[a-zA-Z0-9]{12,32}"#, in: stringToTest)

	return matches.count > 0
}

/// Function for constructing a styled mutable String possibly containing a link or notice
func constructLabelString(stringToTest: String) -> NSMutableAttributedString {
	let linkRegex = #"(?:\[(.+?)\|(.+?)\])"#
	let tooltipRegex = #"(?:\[(tooltip::)(.+?)\])"#

	let linkRanges = getRegexMatches(for: linkRegex, in: stringToTest)
	let tooltipRanges = getRegexMatches(for: tooltipRegex, in: stringToTest)
	let attributedString = NSMutableAttributedString(string: stringToTest)
	
	var indexLeftover = 0
	tooltipRanges.forEach { (range) in
		let swiftRange = Range(range, in: stringToTest)
		let submatch = stringToTest[swiftRange!]
		// submatch: [tooltip::Some Tooltip Content]
		let linkParts = submatch.components(separatedBy: "::")
		let toolTipContent = linkParts[1].dropLast()
		// toolTipContent: Some Tooltip Content
		let linkTitle = Strings.notice
		
		attributedString.mutableString.replaceOccurrences(of: String(submatch), with: linkTitle, options: .literal, range: NSMakeRange(0, attributedString.length))
		
		var coloredRange: NSRange
		if indexLeftover == 0 {
			coloredRange = NSMakeRange(range.location, linkTitle.count)
		} else {
			coloredRange = NSMakeRange(range.location - indexLeftover, linkTitle.count)
		}
		indexLeftover = submatch.count - linkTitle.count

		let attributesForLink = [
			NSAttributedString.Key.foregroundColor: XS2AiOS.shared.styleProvider.tintColor,
			NSAttributedString.Key.underlineColor: XS2AiOS.shared.styleProvider.tintColor,
			NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
			// We use .attachment instead of .link so we can change the colors
			NSAttributedString.Key.attachment: toolTipContent,
		] as [NSAttributedString.Key: Any]
		
		attributedString.setAttributes(attributesForLink, range: coloredRange)
	}

	/// Reset to 0 for the next loop
	indexLeftover = 0

	linkRanges.forEach { (range) in
		let swiftRange = Range(range, in: stringToTest)
		let submatch = stringToTest[swiftRange!]
		// submatch: [some title|link::http://example.com]
		let linkParts = submatch.components(separatedBy: "::")
		let linkTitle = String(linkParts[0].components(separatedBy: "|")[0].dropFirst())
		// linkTitle: some title
		let linkType = linkParts[0].components(separatedBy: "|")[1]
		// linkType: link
		let linkUrlString = linkParts[1].dropLast()
		// linkUrlString: http://example.com

		attributedString.mutableString.replaceOccurrences(of: String(submatch), with: linkTitle, options: .literal, range: NSMakeRange(0, attributedString.length))
		
		var coloredRange: NSRange
		if indexLeftover == 0 {
			coloredRange = NSMakeRange(range.location, linkTitle.count)
		} else {
			coloredRange = NSMakeRange(range.location - indexLeftover, linkTitle.count)
		}
		indexLeftover = submatch.count - linkTitle.count
		
		
		let url: URL
		
		if linkType == "autosubmit" {
			url = URL(string: "autosubmit::\(linkUrlString)")!
		} else {
			if let urlFromLink = URL(string: String(linkUrlString)) {
				url = urlFromLink
			} else {
				return
			}
		}
		
		let attributesForLink = [
			NSAttributedString.Key.foregroundColor: XS2AiOS.shared.styleProvider.tintColor,
			NSAttributedString.Key.underlineColor: XS2AiOS.shared.styleProvider.tintColor,
			NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
			// We use .attachment instead of .link so we can change the colors
			NSAttributedString.Key.attachment: url,
		] as [NSAttributedString.Key: Any]
		
		attributedString.setAttributes(attributesForLink, range: coloredRange)
	}

	return attributedString
}


func imageForBase64String(_ strBase64: String) -> UIImage? {
	do {
		guard let url = URL(string: strBase64) else {
			return nil
		}

		let imageData = try Data(contentsOf: url)

		if let image = UIImage(data: imageData) {
			return image
		}

		return nil
	} catch {
		return nil
	}
}
