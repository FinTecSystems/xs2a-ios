import UIKit
import KeychainAccess

public class XS2A {
	private static var _shared: XS2A?
	internal var currentState: String?

	public var configuration: Configuration
	public let styleProvider: StyleProvider
	public let loadingStateProvider: LoadingStateProvider
	public let keychain: Keychain
	let apiService: APIService
	var backButtonIsPresent: Bool = false

	public var currentStep: WizardStep? {
		didSet {
			XS2A.shared.configuration.onStepChanged(currentStep)
		}
	}

	/**
	 - Parameters:
	  - configuration: The Configuration including the wizardSessionKey for the session to be initialized
	  - styleProvider: The StyleProvider to be used
	  - loadingStateProvider: The LoadingStateProvider to be used
	*/
	init(configuration: Configuration, styleProvider: StyleProvider, loadingStateProvider: LoadingStateProvider = XS2ALoadingStateProvider()) {
		self.configuration = configuration
		self.styleProvider = styleProvider
		self.loadingStateProvider = loadingStateProvider
		self.apiService = APIService(wizardSessionKey: configuration.wizardSessionKey, baseURL: configuration.baseURL)
		
		self.currentStep = nil
		self.keychain = Keychain(service: "\(String(describing: Bundle.main.bundleIdentifier))_XS2A")
	}
	
	public static func clearKeychain() throws {
		do {
			let tempKeychain = Keychain(service: "\(String(describing: Bundle.main.bundleIdentifier))_XS2A")
			try tempKeychain.removeAll()
		} catch (let e) {
			throw e
		}
	}
	
	public static func configure(withConfig configuration: Configuration, withStyle styleProvider: StyleProvider) {
		_shared = XS2A(configuration: configuration, styleProvider: styleProvider, loadingStateProvider: XS2ALoadingStateProvider())
	}

	public static func configure(
		withConfig configuration: Configuration,
		withStyle styleProvider: StyleProvider,
		withLoading loadingStateProvider: LoadingStateProvider
	) {
		_shared = XS2A(configuration: configuration, styleProvider: styleProvider, loadingStateProvider: loadingStateProvider)
	}
	
	public static var shared: XS2A {
		guard let shared = _shared else {
			fatalError("Did you forget to Configure XS2A by calling `XS2A.configure(withConfig:withStyle:)`?")
		}

		return shared
	}
}

extension XS2A {
	public enum Language: String {
		case de = "de"
		case en = "en"
		case fr = "fr"
		case it = "it"
		case es = "es"
	}

	public struct Configuration {
		var wizardSessionKey: String
		var permissionToStoreCredentials: Bool
		var provider: String?
		var backButtonAction: () -> Void
		var onStepChanged: (WizardStep?) -> Void
		var baseURL: String
		var language: Language
		var enableBackButton: Bool
		var redirectDeepLink: String?
		var withScrollView: Bool
		var showPasswordVisiblityToggle: Bool
		
		public init(
			wizardSessionKey: String,
			backButtonAction: @escaping () -> Void = {},
			onStepChanged: @escaping (WizardStep?) -> Void = {_ in },
			baseURL: String = "https://api.xs2a.com/jsonp",
			language: Language? = nil,
			enableBackButton: Bool = true,
			redirectDeepLink: String? = nil,
			withScrollView: Bool = true,
			showPasswordVisiblityToggle: Bool = true
		) {
			self.wizardSessionKey = wizardSessionKey
			self.permissionToStoreCredentials = false
			self.provider = nil
			self.backButtonAction = backButtonAction
			self.onStepChanged = onStepChanged
			self.baseURL = baseURL
			self.redirectDeepLink = redirectDeepLink
			self.withScrollView = withScrollView
			self.showPasswordVisiblityToggle = showPasswordVisiblityToggle
			
			if let language = language {
				self.language = language
			} else if let deviceLanguage = Language(rawValue: String(Locale.preferredLanguages.first?.prefix(2) ?? "de")) {
				/// No language explicitly set but users device language might be in our supported set of languages
				self.language = deviceLanguage
			} else {
				self.language = .de
			}


			self.enableBackButton = enableBackButton
		}
	}
	
	public struct ButtonStyle {
		var textColor: UIColor
		var backgroundColor: UIColor
		var borderWidth: CGFloat
		var borderColor: UIColor
		
		public init(textColor: UIColor, backgroundColor: UIColor, borderWidth: CGFloat = 0, borderColor: UIColor = .clear) {
			self.textColor = textColor
			self.backgroundColor = backgroundColor
			self.borderWidth = borderWidth
			self.borderColor = borderColor
		}
	}
	
	public struct AlertStyle {
		var textColor: UIColor
		var backgroundColor: UIColor
		
		public init(textColor: UIColor, backgroundColor: UIColor) {
			self.textColor = textColor
			self.backgroundColor = backgroundColor
		}
	}

	public struct LinkStyle {
		var textColor: UIColor
		var underlineColor: UIColor
		var underlineStyle: NSUnderlineStyle

		public init(textColor: UIColor, underlineColor: UIColor, underlineStyle: NSUnderlineStyle = .single) {
			self.textColor = textColor
			self.underlineColor = underlineColor
			self.underlineStyle = underlineStyle
		}
	}

	public struct StyleProvider {
		/// General Styles
		var font: Font
		var tintColor: UIColor
		var logoVariation: LogoVariation
		var backgroundColor: UIColor
        var textColor: UIColor
		var errorColor: UIColor
		
		/// Textfield Styles
		var inputBackgroundColor: UIColor
		var inputBorderRadius: CGFloat
		var inputBorderColor: UIColor
		var inputBorderWidth: CGFloat
		var inputBorderWidthActive: CGFloat
		var inputTextColor: UIColor
		var placeholderColor: UIColor
		
		/// Button Styles
		var buttonBorderRadius: CGFloat
		var submitButtonStyle: ButtonStyle
		var backButtonStyle: ButtonStyle
		var abortButtonStyle: ButtonStyle
		var restartButtonStyle: ButtonStyle
		
		/// Alert Styles
		var alertBorderRadius: CGFloat
		var errorStyle: AlertStyle
		var warningStyle: AlertStyle
		var infoStyle: AlertStyle

		var linkStyle: LinkStyle
		
		public enum LogoVariation: String {
			case standard = "logo_standard"
			case white = "logo_white"
			case black = "logo_black"
		}
		
		public init(
			font: FontName = .systemDefault,
			tintColor: UIColor = UIColor(red: 66.0 / 255.0, green: 119.0 / 255.0, blue: 131.0 / 255.0, alpha: 1),
			logoVariation: LogoVariation = .standard,
			backgroundColor: UIColor = .white,
            textColor: UIColor = UIColor(hex: "#262626"),
            errorColor: UIColor = UIColor(hex: "#DB271A"),
			inputBackgroundColor: UIColor = UIColor(hex: "#F5F5F5"),
			inputBorderRadius: CGFloat = 6,
			inputBorderColor: UIColor = .clear,
			inputBorderWidth: CGFloat = 0,
			inputBorderWidthActive: CGFloat = 2,
			inputTextColor: UIColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1),
			placeholderColor: UIColor = UIColor(hex: "#757575"),
			buttonBorderRadius: CGFloat = 6,
			submitButtonStyle: ButtonStyle = ButtonStyle(textColor: .white, backgroundColor: UIColor(red: 66.0 / 255.0, green: 119.0 / 255.0, blue: 131.0 / 255.0, alpha: 1)),
			backButtonStyle: ButtonStyle = ButtonStyle(textColor: .white, backgroundColor: UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.00)),
			abortButtonStyle: ButtonStyle = ButtonStyle(textColor: .white, backgroundColor: UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.00)),
			restartButtonStyle: ButtonStyle = ButtonStyle(textColor: .white, backgroundColor: UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.00)),
			alertBorderRadius: CGFloat = 6,
			errorStyle: AlertStyle = AlertStyle(textColor: .white, backgroundColor: UIColor(hex: "#DB271A")),
			warningStyle: AlertStyle = AlertStyle(textColor: .black, backgroundColor: UIColor(red: 254.0 / 255.0, green: 174.0 / 255.0, blue: 34.0 / 255.0, alpha: 1)),
			infoStyle: AlertStyle = AlertStyle(textColor: .white, backgroundColor: UIColor(hex: "#0B809D")),
			linkStyle: LinkStyle? = nil
		) {
			self.font = Font(fontName: font)
			self.tintColor = tintColor
			self.logoVariation = logoVariation
			self.backgroundColor = backgroundColor
			self.textColor = textColor
            self.errorColor = errorColor
			self.inputBackgroundColor = inputBackgroundColor
			self.inputBorderRadius = inputBorderRadius
			self.inputBorderColor = inputBorderColor
			self.inputBorderWidth = inputBorderWidth
			self.inputBorderWidthActive = inputBorderWidthActive
			self.inputTextColor = inputTextColor
			self.placeholderColor = placeholderColor
			self.buttonBorderRadius = buttonBorderRadius
			self.submitButtonStyle = submitButtonStyle
			self.backButtonStyle = backButtonStyle
			self.abortButtonStyle = abortButtonStyle
			self.restartButtonStyle = restartButtonStyle
			self.alertBorderRadius = alertBorderRadius
			self.errorStyle = errorStyle
			self.warningStyle = warningStyle
			self.infoStyle = infoStyle

			if let linkStyle = linkStyle {
				self.linkStyle = linkStyle
			} else {
				self.linkStyle = LinkStyle(textColor: tintColor, underlineColor: tintColor, underlineStyle: .single)
			}
		}
	}
}
