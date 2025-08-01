![header](https://demo.xs2a.com/img/ios-sdk-header.png)

# XS2AiOS - Native iOS SDK for XS2A
![License](https://img.shields.io/badge/license-MIT%20%2B%20file%20LICENSE-F89572.svg)
![Platform](https://img.shields.io/badge/platform-iOS-F89572.svg)
![Languages](https://img.shields.io/badge/languages-swift-F89572.svg)
![Swift Package Manager](https://img.shields.io/badge/SPM-supported-F89572.svg)
![Cocoapods](https://img.shields.io/cocoapods/v/XS2AiOS?color=F89572&logo=FinTecSystems&logoColor=F89572)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-F89572.svg?style=flat)](https://github.com/Carthage/Carthage)


This iOS SDK allows for the integration of XS2A into native iOS apps.
An [Android SDK](https://github.com/FinTecSystems/xs2a-android) and a [React Native SDK](https://github.com/FinTecSystems/xs2a-react-native) is also available.


### Demo Screencast

A demo screencast of the test bank login flow can be found [here](https://demo.xs2a.com/img/ios-screencast.webp).


## How to Integrate

### Requirements

- iOS >= 12.0

### Estimated Binary Size

When measured with [cocoapods-size](https://github.com/google/cocoapods-size), the reported combined size added is ~1,87 Megabytes (for version 1.1.4).

### Swift Package Manager (Preferred)
Use Xcode's `File -> Swift Packages -> Add Package Dependency` (Xcode 12) or `File -> Add Packages...` (Xcode 13) to add this package.
Use the URL of this repository for this:

```
https://github.com/FinTecSystems/xs2a-ios
```

### Cocoapods
Include the pod in your Podfile:

```
pod "XS2AiOS"
```

Then run `pod install`. In some cases you might have to run `pod install --repo-update`.

### Carthage
In case you want to integrate the module as XCFramework via Carthage, add the following lines to your Cartfile:

```
github "FinTecSystems/xs2a-ios"
github "ninjaprox/NVActivityIndicatorView" ~> 5.1.1
github "SwiftyJSON/SwiftyJSON" ~> 5.0.1
github "kishikawakatsumi/KeychainAccess" ~> 4.2.2
```

Then run `carthage update --use-xcframeworks --platform iOS` and drag the resulting XCFrameworks into your Xcode projects' framework section.
## Usage
```swift
import XS2AiOS
```

### Configure and Present the View
The SDK exposes a `XS2AViewController` that you can show at the appropriate time to the customer.
Before doing so, you need to `configure` the SDK first.
The `XS2AViewController` will guide the customer through the process. After that process is finished, you will receive a callback as described below.

```swift
let config = XS2A.Configuration(
  /*
   * Required: The Session Key from the XS2A API.
   */
  wizardSessionKey: "YOUR_WIZARD_SESSION_KEY",
  /*
   * (Optional)
   * Use .de/.en/.fr/.es/.it to overwrite session language.
   * Default is device language if part of supported languages,
   * otherwise fallback to .en.
   */
  language: .en,
  /*
   * (Optional)
   * Boolean to control whether the exposes View from XS2AViewController
   * is an UIScrollView (default) or an UIView.
   */
  withScrollView: true,
  /*
   * (Optional)
   * If you want to show a small eye icon at the end of a password 
   * input textfield, that allows to toggle showing (unmasking) the password.
   */
  showPasswordVisiblityToggle: true,
  /*
   * (Optional)
   * Whether the SDK has permission to store users credentials on the Keychain.
   * This is a feature that first needs to be enabled by Tink Support for your account
   * before also enabling it here.
   */
  permissionToStoreCredentials: false,
  /*
   * (Optional)
   * You can disable the back button shown during sessions here.
   * WARNING: Carefully read the section "Implementing Custom Back Button" below before doing so.
   */
  enableBackButton: true,
  /*
   * (Optional)
   * You can register a function that will be called when the back button has been pressed.
   * Read the "Get Current Step & Registering Custom Back Button Function" section below for more info.
   */
  backButtonAction: @escaping () -> Void = {},
  /*
   * (Optional)
   * You can register a function that will be called when the step has changed.
   * Read the "Get Current Step & Registering Custom Back Button Function" section below for more info.
   */
  onStepChanged: @escaping (WizardStep?) -> Void = {_ in },
  /*
   * (Optional)
   * Register the deeplink to be redirected to after a bank redirection.
   * Read https://github.com/FinTecSystems/xs2a-ios/releases/tag/1.14.0 for detailed info.
   */
  redirectDeepLink: nil,
)

// See the detailed Styling API below
let style = XS2A.StyleProvider()

XS2A.configure(
  withConfig: config,
  withStyle: style
)

// Reference to the VC in order to present and dismiss it
var xs2aViewController: XS2AViewController?

self.xs2aViewController = XS2AViewController { result in
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
  /**
   Session errors occur during a session.
   Implementation of the different cases below is optional.
   No action needs to be taken for them, in fact we recommend
   to let the user handle the completion of the session until one of the above .success or .failure cases is called.
   You can however use below cases for measuring purposes.
   NOTE: Should you decide to do navigation to different screens based on below cases, you should only do so
   in case of the recoverable parameter being false, otherwise the user can still finish the session.
   */
  case .sessionError(let sessionError):
    switch sessionError {
      case .loginFailed(recoverable: let recoverable):
        // Login to bank failed (e.g. invalid login credentials)
      case .sessionTimeout(recoverable: let recoverable):
        // The customer's session has timed out.
      case .tanFailed(recoverable: let recoverable):
        // User entered invalid TAN.
      case .techError(recoverable: let recoverable):
        // An unknown or unspecified error occurred.
      case .testmodeError(recoverable: let recoverable):
        // An error occurred using testmode settings.
      case .transNotPossible(recoverable: let recoverable):
        // A transaction is not possible for various reasons.
      case .validationFailed(recoverable: let recoverable):
        // Validation error (e.g. entered letters instead of numbers).
      case .other(errorCode: let errorCode, recoverable: let recoverable):
        // Other errors.
    }
  }
}

// present the configured view
self.present(self.xs2aViewController!, animated: true, completion: nil)
```

#### Get Current Step & Registering Custom Back Button Function

Some use cases require that the current step of the session is known and/or that a callback can be registered for when the back button is tapped.

You can be notified when the back button has been pressed by passing a `backButtonAction` function with the configuration:

```swift
func backButtonTapped() {
  /// get the current step of the session
  let currentStep = XS2A.shared.currentStep
  
  if (currentStep == .login) {
    /// e.g. do something when the back button is pressed during the login step
  }
}
```

If you want to be notified when the step of the session has changed, you can pass a `onStepChanged` callback with the configuration:

```swift
func stepHasChanged(step: WizardStep?) {
  // session step has changed
}

let config = XS2A.Configuration(
  wizardSessionKey: key,
  backButtonAction: backButtonTapped,
  onStepChanged: stepHasChanged
)
```

In case you need to know if you the session is on the bank search screen or on the very first login screen, there are two methods
available:

```swift
// Will return true/false depending on if the session is on the bank search screen
self.xs2aViewController.isBankSearch()

// Will return true/false depending on if the session is on *first* login screen,
// will return false if on any additional login screens
self.xs2aViewController.isLogin()
```

#### Implementing Custom Back Button

For certain use cases it is necessary to not show the default back button inside the form, but instead use a different custom element as
the back button, which functionally should of course behave the same. This is possible by setting `enableBackButton` to `false` in the config:

> Only disable the back button if you are going to implement your own back button!

```swift
let config = XS2A.Configuration(
  // ...
  enableBackButton: false,
)
```

This will not show the back button in the XS2AViewController anymore. You should then built your own button which can then call
`goBack()` on the XS2AViewController:

```swift
self.xs2aViewController.goBack()
```

### Styling API

You can style the view according to your needs. Please note, that dark mode is overriden inside the module, but you can of course simply define another style provider for dark mode.

#### Custom Loading Animation

You can overwrite the default loading animation by building your own logic that implements the `LoadingStateProvider` protocol. 

`showLoadingIndicator` and `hideLoadingIndicator` methods displays full screen loading state over provided view controller.
The `loadingIndicatorView` provides view that is embedded in `AutosubmitLine` Form component.

You can then pass your class via the configure method:

```swift
class MyCustomLoadingProvider: LoadingStateProvider {
  func showLoadingIndicator(title: String, message: String, over viewController: UIViewController) {
    // Logic that shows a loading animation over the passed `viewController`
  }

  func hideLoadingIndicator(over viewController: UIViewController) {
    // Logic that hides the loading animation
  }

  var loadingIndicatorView: LoadingView {
    // Returns UIView that displays the loading, for example:
    // NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50), type: .lineScale, color: .blue)
    return MyCustomLoadingView()
  }

  // UIView that implements the LoadingView protocol
  class MyCustomLoadingView: LoadingView {
    func startAnimating() { ... }   
    func stopAnimating() { ... }
  }
}

let myCustomLoadingAnimation = MyCustomLoadingProvider()

XS2A.configure(
  withConfig: config,
  withStyle: style,
  withLoading: myCustomLoadingAnimation
)
```

#### Colors, Buttons & other Styles

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
var inputBorderColor: UIColor
var inputBorderWidth: CGFloat
var inputBorderWidthActive: CGFloat
var inputTextColor: UIColor
var placeholderColor: UIColor

/// Button Styles
var buttonBorderRadius: CGFloat
var submitButtonStyle: ButtonStyle /// (textColor, backgroundColor, borderWidth and borderColor)
var backButtonStyle: ButtonStyle
var abortButtonStyle: ButtonStyle
var restartButtonStyle: ButtonStyle

/// Alert Styles
var alertBorderRadius: CGFloat
var errorStyle: AlertStyle /// (textColor & backgroundColor)
var warningStyle: AlertStyle
var infoStyle: AlertStyle

var linkStyle: LinkStyle /// (textColor, underlineColor and underlineStyle)

```
![Styling API](https://demo.xs2a.com/img/ios-styling.jpg)

### Encryption Export Compliance Information

When uploading your app to App Store Connect, Apple typically wants to know some information on whether your app uses encryption and if it qualifies for an exemption 
under Category 5, Part 2 of the U.S. Export Administration Regulations. This SDK *does* qualify for such exemption, namely article `(d)`:

> Specially designed and limited for banking use or "money transactions"

Please note, that this only applies to this SDK and the corresponding `XS2AiOSNetService`, but not to any other parts of your app, which might not qualify 
for such exemptions and you might have to reconsider how to answer that dialog.

### License

Please note that this mobile SDK is subject to the MIT license. MIT license does not apply to the logo of Tink Germany GmbH, the terms of use and the privacy policy of Tink Germany GmbH. The license terms of the logo of Tink Germany GmbH, the terms of use and the privacy policy of Tink Germany GmbH are included in the LICENSE as Tink Germany LICENSE.
