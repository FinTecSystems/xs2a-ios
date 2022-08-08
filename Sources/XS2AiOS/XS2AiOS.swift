import UIKit
import KeychainAccess

public class XS2AiOS {
	private static var _shared: XS2AiOS?

	public var configuration: Configuration
	public let styleProvider: StyleProvider
    public let loadingStateProvider: LoadingStateProvider
	public let keychain: Keychain
	let apiService: APIService
	
	public var currentStep: WizardStep? {
		didSet {
			XS2AiOS.shared.configuration.onStepChanged(currentStep)
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
		_shared = XS2AiOS(configuration: configuration, styleProvider: styleProvider, loadingStateProvider: XS2ALoadingStateProvider())
	}

    public static func configure(
        withConfig configuration: Configuration,
        withStyle styleProvider: StyleProvider,
        withLoading loadingStateProvider: LoadingStateProvider
    ) {
        _shared = XS2AiOS(configuration: configuration, styleProvider: styleProvider, loadingStateProvider: loadingStateProvider)
    }
	
	public static var shared: XS2AiOS {
		guard let shared = _shared else {
			fatalError("Did you forget to Configure XS2A by calling `XS2A.configure(withConfig:withStyle:)`?")
		}

		return shared
	}
}

extension XS2AiOS {
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
		var language: Language?
		
		public init(
			wizardSessionKey: String,
			backButtonAction: @escaping () -> Void = {},
			onStepChanged: @escaping (WizardStep?) -> Void = {_ in },
			baseURL: String = "https://api.xs2a.com/jsonp",
			language: Language? = nil
		) {
			self.wizardSessionKey = wizardSessionKey
			self.permissionToStoreCredentials = false
			self.provider = nil
			self.backButtonAction = backButtonAction
			self.onStepChanged = onStepChanged
			self.baseURL = baseURL
			
			if let language = language {
				self.language = language
			}
		}
	}
	
	public struct ButtonStyle {
		var textColor: UIColor
		var backgroundColor: UIColor
		
		public init(textColor: UIColor, backgroundColor: UIColor) {
			self.textColor = textColor
			self.backgroundColor = backgroundColor
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
	
	public struct StyleProvider {
		/// General Styles
		var font: Font
		var tintColor: UIColor
		var logoVariation: LogoVariation
		var backgroundColor: UIColor
		var textColor: UIColor
		
		/// Textfield Styles
		var inputBackgroundColor: UIColor
		var inputBorderRadius: CGFloat
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
			textColor: UIColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1),
			inputBackgroundColor: UIColor = UIColor(red: 0.96, green: 0.97, blue: 0.98, alpha: 1.00),
			inputBorderRadius: CGFloat = 6,
			inputTextColor: UIColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1),
			placeholderColor: UIColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.00),
			buttonBorderRadius: CGFloat = 6,
			submitButtonStyle: ButtonStyle = ButtonStyle(textColor: .white, backgroundColor: UIColor(red: 66.0 / 255.0, green: 119.0 / 255.0, blue: 131.0 / 255.0, alpha: 1)),
			backButtonStyle: ButtonStyle = ButtonStyle(textColor: .white, backgroundColor: UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.00)),
			abortButtonStyle: ButtonStyle = ButtonStyle(textColor: .white, backgroundColor: UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.00)),
			restartButtonStyle: ButtonStyle = ButtonStyle(textColor: .white, backgroundColor: UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.00)),
			alertBorderRadius: CGFloat = 6,
			errorStyle: AlertStyle = AlertStyle(textColor: .white, backgroundColor: UIColor(red: 234.0 / 255.0, green: 84.0 / 255.0, blue: 74.0 / 255.0, alpha: 1)),
			warningStyle: AlertStyle = AlertStyle(textColor: .black, backgroundColor: UIColor(red: 254.0 / 255.0, green: 174.0 / 255.0, blue: 34.0 / 255.0, alpha: 1)),
			infoStyle: AlertStyle = AlertStyle(textColor: .white, backgroundColor: UIColor(red: 0.05, green: 0.62, blue: 0.76, alpha: 1.00))
		) {
			self.font = Font(fontName: font)
			self.tintColor = tintColor
			self.logoVariation = logoVariation
			self.backgroundColor = backgroundColor
			self.textColor = textColor
			self.inputBackgroundColor = inputBackgroundColor
			self.inputBorderRadius = inputBorderRadius
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
		}
	}
}
