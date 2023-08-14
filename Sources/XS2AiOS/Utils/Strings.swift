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
	static let bankingApp = getStringForKey(key: "Banking_App")
	static let website = getStringForKey(key: "Website")


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
	
	enum RedirectAppPrompt {
		static let title = getStringForKey(key: "RedirectAppPrompt.Title")
		static let message = getStringForKey(key: "RedirectAppPrompt.Message")
	}
}

extension String {
	static func localized(key: String) -> String {
		guard let path = Bundle.current.path(forResource: XS2AiOS.shared.configuration.language.rawValue, ofType: "lproj") else {
			fatalError("Bundle path not found for resource \(XS2AiOS.shared.configuration.language.rawValue)")
		}
		
		guard let bundle = Bundle(path: path) else {
			fatalError("Bundle not found for path \(path)")
		}

		return NSLocalizedString(key, tableName: nil, bundle: bundle, value: "", comment: "")
	}
}
