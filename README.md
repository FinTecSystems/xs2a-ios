![header](https://fintecsystems.com/iOS_SDK_Header.jpg)
# XS2AiOS - Native iOS SDK for XS2A

This iOS SDK allows for the integration of XS2A into native iOS apps.
An [Android SDK](https://github.com/FinTecSystems/xs2a-android) is also available.


### Demo Screencast
<img src="https://fintecsystems.com/ios_sdk_testbank_screencast.webp" alt="Screencast Demo" height="400"/>

## How to Integrate

### Include the Module via Swift Package Manager
Use Xcode's `File -> Swift Packages -> Add Package Dependency` (Xcode 12) or `File -> Add Packages...` (Xcode 13) to add this package.
Use the URL of this repository (`https://github.com/FinTecSystems/xs2a-ios`) for this.

### Import the Module
```swift
import XS2AiOS
```

### Configure and Present the View
The SDK exposes a `XS2AViewController` that you can show at the appropriate time to the customer.
Before doing so, you need to `configure` the SDK first.
The `XS2AViewController` will guide the customer through the process. After that process is finished, you will receive a callback as described below.

```swift
let config = XS2AiOS.Configuration(wizardSessionKey: "YOUR_WIZARD_SESSION_KEY")

// See the detailed Styling API below
let style = XS2AiOS.StyleProvider()

XS2AiOS.configure(withConfig: config, withStyle: style)

let xs2aView = XS2AViewController { result in
	switch result {
	case .success(.finish):
		// e.g. present a success view
	case .success(.finishWithCredentials(let credentials)):
		// only called for XS2A.API with connection sync_mode set to "shared"
		// will return the shared credentials
		// e.g. present a success view
	case .failure(let error):
		switch error {
		case .userAborted:
			// the user pressed the abort button or
			// swiped down to abort in case of popover presentation
			// e.g. present an abort view
		case .networkError:
			// a network error occurred
			// e.g. present an error view
		}
	}
}

// present the configured view
self.present(xs2aView, animated: true, completion: nil)
```

### Styling API

You can style the view according to your needs. Please note, that dark mode is overriden inside the module, but you can of course simply define another style provider for dark mode.

The available properties are:

```swift
/// General Styles
var font: Font /// .custom("FontNameHere") or .systemDefault
var tintColor: UIColor
var logoVariation: LogoVariation /// (default as shown below, all white or all black)
var backgroundColor: UIColor
var textColor: UIColor

/// Textfield Styles
var inputBackgroundColor: UIColor
var inputBorderRadius: CGFloat
var inputTextColor: UIColor
var placeholderColor: UIColor

/// Button Styles
var buttonBorderRadius: CGFloat
var submitButtonStyle: ButtonStyle /// (textColor & backgroundColor)
var backButtonStyle: ButtonStyle
var abortButtonStyle: ButtonStyle
var restartButtonStyle: ButtonStyle

/// Alert Styles
var alertBorderRadius: CGFloat
var errorStyle: AlertStyle /// (textColor & backgroundColor)
var warningStyle: AlertStyle
var infoStyle: AlertStyle

```
![Styling API](https://fintecsystems.com/StylingAPI.png)
