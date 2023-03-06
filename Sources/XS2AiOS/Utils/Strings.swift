import Foundation

func getStringForKey(key: String) -> String {
	return String.localized(key: key)
}

enum Strings {
	static let yes = getStringForKey(key: "Yes")
	static let no = getStringForKey(key: "No")
	static let notice = getStringForKey(key: "Notice")
	static let choose = getStringForKey(key: "Choose")
	static let next = getStringForKey(key: "Next")

	enum Alert {
		static let close = getStringForKey(key: "Alert.Close")

		enum Abort {
			static let title = getStringForKey(key: "Alert.Abort.Title")
			static let message = getStringForKey(key: "Alert.Abort.Message")
		}
		enum Imprint {
			static let title = getStringForKey(key: "Alert.Imprint.Title")
			static let message = getStringForKey(key: "Alert.Imprint.Message")
			static let link = getStringForKey(key: "Alert.Imprint.Link")
			static let linkText = getStringForKey(key: "Alert.Imprint.LinkText")
		}
	}
	
	enum AutocompleteView {
		static let notice = getStringForKey(key: "AutocompleteView.Notice")
		static let ibanTypingNotice = getStringForKey(key: "AutocompleteView.IBANTypingNotice")
		static let ibanTooLongNotice = getStringForKey(key: "AutocompleteView.IBANTooLongNotice")
	}
	
	enum AutofillQuestion {
		static let title = getStringForKey(key: "AutofillQuestion.Title")
		static let text = getStringForKey(key: "AutofillQuestion.Text")
	}
	
	enum OfflineNotice {
		static let title = getStringForKey(key: "OfflineNotice.Title")
		static let text = getStringForKey(key: "OfflineNotice.Text")
	}
}

extension String {
	static func localized(key: String) -> String {
		let path = Bundle.current.path(forResource: XS2AiOS.shared.configuration.language.rawValue, ofType: "lproj")
		let bundle = Bundle(path: path!)

		return NSLocalizedString(key, tableName: nil, bundle: bundle!, value: "", comment: "")
	}
}
