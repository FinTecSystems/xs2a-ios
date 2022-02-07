import UIKit

public class XS2AiOS {
	private static var _shared: XS2AiOS?
	public let configuration: Configuration
	public let styleProvider: StyleProvider
	let apiService: APIService
	
	public var currentStep: WizardStep?

	/**
	 - Parameters:
	  - configuration: The Configuration including the wizardSessionKey for the session to be initialized
	  - styleProvider: The StyleProvider to be used
	*/
	init(configuration: Configuration, styleProvider: StyleProvider) {
		self.configuration = configuration
		self.styleProvider = styleProvider
		self.apiService = APIService(wizardSessionKey: configuration.wizardSessionKey, baseURL: configuration.baseURL)
		
		self.currentStep = nil
	}
	
	public static func configure(withConfig configuration: Configuration, withStyle styleProvider: StyleProvider) {
		_shared = XS2AiOS(configuration: configuration, styleProvider: styleProvider)
	}
	
	public static var shared: XS2AiOS {
		guard let shared = _shared else {
			fatalError("Did you forget to Configure XS2A by calling `XS2A.configure(withConfig:withStyle:)`?")
		}

		return shared
	}
}

extension XS2AiOS {
	public struct Configuration {
		var wizardSessionKey: String
		var backButtonAction: () -> Void
		var baseURL: String
		
		public init(
			wizardSessionKey: String,
			backButtonAction: @escaping () -> Void = {},
			baseURL: String = "https://api.xs2a.com/jsonp"
		) {
			self.wizardSessionKey = wizardSessionKey
			self.backButtonAction = backButtonAction
			self.baseURL = baseURL
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
			tintColor: UIColor = UIColor(red: 0.11, green: 0.45, blue: 0.72, alpha: 1.0),
			logoVariation: LogoVariation = .standard,
			backgroundColor: UIColor = .white,
			textColor: UIColor = UIColor(red: 0.27, green: 0.27, blue: 0.28, alpha: 1.0),
			inputBackgroundColor: UIColor = UIColor(red: 0.91, green: 0.95, blue: 0.97, alpha: 1.0),
			inputBorderRadius: CGFloat = 6,
			inputTextColor: UIColor = UIColor(red: 0.27, green: 0.27, blue: 0.28, alpha: 1.0),
			placeholderColor: UIColor = .systemGray,
			buttonBorderRadius: CGFloat = 6,
			submitButtonStyle: ButtonStyle = ButtonStyle(textColor: .white, backgroundColor: UIColor(red: 0.11, green: 0.45, blue: 0.72, alpha: 1.0)),
			backButtonStyle: ButtonStyle = ButtonStyle(textColor: .white, backgroundColor: .systemGray),
			abortButtonStyle: ButtonStyle = ButtonStyle(textColor: .white, backgroundColor: .systemGray),
			restartButtonStyle: ButtonStyle = ButtonStyle(textColor: .white, backgroundColor: .systemGray),
			alertBorderRadius: CGFloat = 6,
			errorStyle: AlertStyle = AlertStyle(textColor: .white, backgroundColor: .systemRed),
			warningStyle: AlertStyle = AlertStyle(textColor: .black, backgroundColor: .systemOrange),
			infoStyle: AlertStyle = AlertStyle(textColor: .white, backgroundColor: UIColor(red: 0.11, green: 0.45, blue: 0.72, alpha: 1.0))
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
