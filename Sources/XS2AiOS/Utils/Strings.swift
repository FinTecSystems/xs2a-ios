import Foundation

enum Strings {
	static let yes = NSLocalizedString("Yes", tableName: nil, bundle: .module, value: "", comment: "")
	static let no = NSLocalizedString("No", tableName: nil, bundle: .module, value: "", comment: "")
	static let notice = NSLocalizedString("Notice", tableName: nil, bundle: .module, value: "", comment: "")
	static let choose = NSLocalizedString("Choose", tableName: nil, bundle: .module, value: "", comment: "")
	static let next = NSLocalizedString("Next", tableName: nil, bundle: .module, value: "", comment: "")

	enum Alert {
		static let close = NSLocalizedString("Alert.Close", tableName: nil, bundle: .module, value: "", comment: "")

		enum Abort {
			static let title = NSLocalizedString("Alert.Abort.Title", tableName: nil, bundle: .module, value: "", comment: "")
			static let message = NSLocalizedString("Alert.Abort.Message", tableName: nil, bundle: .module, value: "", comment: "")
		}
		enum Imprint {
			static let title = NSLocalizedString("Alert.Imprint.Title", tableName: nil, bundle: .module, value: "", comment: "")
			static let message = NSLocalizedString("Alert.Imprint.Message", tableName: nil, bundle: .module, value: "", comment: "")
			static let link = NSLocalizedString("Alert.Imprint.Link", tableName: nil, bundle: .module, value: "", comment: "")
			static let linkText = NSLocalizedString("Alert.Imprint.LinkText", tableName: nil, bundle: .module, value: "", comment: "")
		}
	}
	
	enum AutocompleteView {
		static let notice = NSLocalizedString("AutocompleteView.Notice", tableName: nil, bundle: .module, value: "", comment: "")
		static let ibanTypingNotice = NSLocalizedString("AutocompleteView.IBANTypingNotice", tableName: nil, bundle: .module, value: "", comment: "")
		static let ibanTooLongNotice = NSLocalizedString("AutocompleteView.IBANTooLongNotice", tableName: nil, bundle: .module, value: "", comment: "")
	}
}
