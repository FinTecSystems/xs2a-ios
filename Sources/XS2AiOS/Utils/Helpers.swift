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

/**
 Used for splitting the complete input string into an array of groups, like:
 `hallo [bold text|bold] and [italic text|italic] and [br] and [Some Link|link::http://google.de] and [Some Dialog|dialog::http://localhost:8000/privacy/1/html] and [Some Autosubmit|autosubmit::name=value&name2=value2]`
 becomes:
 `["hallo ", "[Some bold text|bold]", " and ", "[Some italic text|italic]", " and line break ", "[br]", " and ", "[Some Link|link::http://google.de]", " and ", "[Some Dialog|dialog::http://localhost:8000/privacy/1/html]", " and ", "[Some Autosubmit|autosubmit::name=value&name2=value2]"]`
 */
func splitStringToGroups(stringToTest: String) -> [String] {
	let pattern = #"\[.*?\]|([^\[\]]+)"#
	let regex = try! NSRegularExpression(pattern: pattern)
	let stringRange = NSRange(location: 0, length: stringToTest.utf16.count)
	let matches = regex.matches(in: stringToTest, range: stringRange)

	var result: [String] = []
	for match in matches {
		result.append((stringToTest as NSString).substring(with: match.range))
	}

	return result
}

/// Function for constructing a styled mutable String possibly containing a link or notice
func constructLabelString(stringToTest: String) -> NSMutableAttributedString {
	let labelString = NSMutableAttributedString(string: "")
	let stringGroups = splitStringToGroups(stringToTest: stringToTest)
	
	let markupRegex = #"(?:\[(.+?)\|(.+?)\])"#

	stringGroups.forEach { stringGroup in
		// stringGroup can be any of:
		// - "hallo " (no markup)
		// - "[br]" (linebreak)
		// - "[text|italic]" (italic text)
		// - "[text|bold]" (bold text)
		// - "[text|link::http...]" (tappable link)
		// - "[text|dialog::http...]" (tappable link)
		// - "[text|autosubmit::...]" (tappable autosbumit)

		// Trim whitespaces, easier to add it back later
		let trimmedStringGroup = stringGroup.trimmingCharacters(in: .whitespaces)

		// Check if a linebreak
		if trimmedStringGroup == "[br]" {
			labelString.append(NSAttributedString(string: "\n"))
			return
		}
		
		// Search for markup Matches within the stringGroup
		let markupMatches = getRegexMatches(for: markupRegex, in: trimmedStringGroup)
		
		if markupMatches.count > 0 {
			// markupMatches contains most likely always a single element
			markupMatches.forEach { matchRange in
				let swiftRange = Range(matchRange, in: trimmedStringGroup)
				let submatch = trimmedStringGroup[swiftRange!]

				if submatch.contains("::") == false {
					// either of italic or bold type
					let markupParts = submatch.components(separatedBy: "|")
					let markupText = markupParts[0].dropFirst() // text
					let markupType = markupParts[1].dropLast() // italic/bold
					
					var traitToUse: UIFontDescriptor.SymbolicTraits
					
					if markupType == "italic" {
						traitToUse = .traitItalic
					} else {
						traitToUse = .traitBold
					}

					let attributesForLink = [
						NSAttributedString.Key.font: XS2AiOS.shared.styleProvider.font.getFont(ofSize: 13, ofWeight: traitToUse)
					] as [NSAttributedString.Key: Any]
					
					labelString.append(NSAttributedString(string: String(markupText), attributes: attributesForLink))
					// Append Space
					labelString.append(NSAttributedString(string: " "))
				} else {
					// link, dialog or autosubmit
					let linkParts = submatch.components(separatedBy: "::")
					let linkTitle = String(linkParts[0].components(separatedBy: "|")[0].dropFirst()) // text
					let linkType = linkParts[0].components(separatedBy: "|")[1] // autosubmit or https
					let linkUrlString = linkParts[1].dropLast()

					// Construct URL
					let url: URL
					if linkType == "autosubmit" {
						// Custom Scheme for autosubmit
						url = URL(string: "autosubmit::\(linkUrlString)")!
					} else {
						if let urlFromLink = URL(string: String(linkUrlString)) {
							url = urlFromLink
						} else {
							// Constructing URL failed, return
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
					
					labelString.append(NSAttributedString(string: linkTitle, attributes: attributesForLink))

					// Append Space
					labelString.append(NSAttributedString(string: " "))
				}
			}
		} else {
			// No markup match, simply append as is with a space.
			labelString.append(NSAttributedString(string: "\(trimmedStringGroup) "))
		}
	}
	
	return labelString
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
