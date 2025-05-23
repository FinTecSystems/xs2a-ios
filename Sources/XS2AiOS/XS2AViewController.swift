import UIKit
import KeychainAccess
import LocalAuthentication
import SafariServices
import Network

/// Delegate used for communicating between this ViewController and the different FormLines
protocol ActionDelegate {
	func sendAction(actionType: XS2AButtonType, withLoadingIndicator: Bool, additionalPayload: Dictionary<String, Any>?)
	func getCountryId() -> String
	func findNextResponder(index: Int, textField: UITextField) -> Bool
	func openLink(url: URL)
}

protocol NetworkNotificationDelegate {
	func cancelNetworkTask() -> Void
	func notifyOfSessionError(error: XS2ASessionError) -> Void
}

public class XS2AViewController: UIViewController, UIAdaptivePresentationControllerDelegate, ActionDelegate, NetworkNotificationDelegate {
	/// If the SDK is currently busy with networking
	private var isBusy = false

	/// The result of the session, set after the process has been completed by the user
	private var result: XS2AResult<XS2ASuccess, XS2AError, XS2ASessionError>?
	
	/// The payload to send to XS2A backend
	private var payload: [String: Any] = [:]

	/// Completion handler registered by the host app
	private let permanentCompletion: ((XS2AResult<XS2ASuccess, XS2AError, XS2ASessionError>) -> Void)?

	/// Instance of APIService
	/// Used for making network requests
	private let ApiService: APIService
	
	/// Boolean keeping track if network connection exists or not
	private var networkConnected = true

	/// The top level view of this ViewController
	/// It wraps all the other subviews and expands if necessary (e.g. keyboard open)
	private lazy var scrollView: UIScrollView = {
		let scrollView = UIScrollView()
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.showsVerticalScrollIndicator = false
		
		return scrollView
	}()

	/// A regular UIView wrapping the stack view
	private lazy var contentView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		
		return view
	}()
	
	/// The vertically aligned stack view which contains the form elements
	private lazy var stackView: UIStackView = {
		let stackView = UIStackView()
		stackView.axis = .vertical
		stackView.distribution = .fill
		stackView.alignment = .fill
		stackView.translatesAutoresizingMaskIntoConstraints = false
		   
		return stackView
	}()
	
	/// Authentication Context
	private lazy var context: LAContext = {
		let mainContext = LAContext()
		mainContext.touchIDAuthenticationAllowableReuseDuration = 60

		return mainContext
	}()
	
	/// Context used for checking if items exist.
	/// Deliberately has no interaction allowed.
	private lazy var internalContext: LAContext = {
		let mainContext = LAContext()
		mainContext.interactionNotAllowed = true

		return mainContext
	}()
	
	/// Bool to set whether to expose a UIScrollView (default)
	/// or a UIView instead
	private lazy var withScrollView: Bool = true
	
	/// Initializer called by host app
	public init(xs2a: XS2A = .shared, completion: @escaping (XS2AResult<XS2ASuccess, XS2AError, XS2ASessionError>) -> Void) {
		self.ApiService = xs2a.apiService
		self.permanentCompletion = completion
		super.init(nibName: nil, bundle: nil)

		self.ApiService.notificationDelegate = self
		self.withScrollView = xs2a.configuration.withScrollView

	}
	

	/// Function that tears down the form elements
	private func hideElements(completion: @escaping () -> Void) {
		if self.children.contains(where: { $0 is AutosubmitLine }) {
			/// We remove the autosubmitline without animation, as it would get animated over and over again
			self.stackView.subviews.forEach({
				if $0.tag != 999 {
					$0.removeFromSuperview()
				}
			})
			self.children.forEach({ $0.removeFromParent() })
			self.hideLoadingIndicator()
			completion()
			self.preferredContentSize = self.contentView.bounds.size
			return
		}
		
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 1, options: .curveEaseOut) {
			self.stackView.subviews.forEach({
				if $0.tag != 999 {
					$0.isHidden = true
					$0.alpha = 0
				}
			})
			self.stackView.layoutIfNeeded()
			self.preferredContentSize = .zero
		} completion: { (_) in
			self.children.forEach({ $0.removeFromParent() })
			self.hideLoadingIndicator()
			completion()
			self.preferredContentSize = self.contentView.bounds.size
		}
	}
	
	/**
	 Function responsible for setting up the form elements
	 - Parameters:
	   - formElements: Array of form elements to show
	   - shouldAnimate: A boolean indicating whether to animate or not
	*/
	private func setupViews(formElements: [FormLine], shouldAnimate: Bool = true) {
		/// If the batch of formElements to setup contains an AutosubmitLine, we skip animations (see further down)
		let containsAutoSubmit = formElements.contains(where: { $0 is AutosubmitLine })

		hideElements {
			for (_, currentFormElement) in formElements.enumerated() {
				/// We set the actionDelegate to this ViewController which handles all actions
				currentFormElement.actionDelegate = self
				
				if currentFormElement is AutosubmitLine {
					if let asAutosubmitLine = currentFormElement as? AutosubmitLine {
						asAutosubmitLine.networkDelegate = self
					}
				}

				guard let initializedView = currentFormElement.view else {
					continue
				}

				self.addChild(currentFormElement)
				currentFormElement.didMove(toParent: self)
				
				if (shouldAnimate && containsAutoSubmit == false) {
					initializedView.alpha = 0
					initializedView.isHidden = true
				}

				self.stackView.addArrangedSubview(initializedView)
				self.view.layoutIfNeeded()

				if shouldAnimate == true && containsAutoSubmit == false {
					UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 5, options: .curveEaseInOut) {
						initializedView.isHidden = false
						initializedView.alpha = 1
					}
				}
				
				self.stackView.addCustomSpacing(CGFloat(12), after: initializedView)
			}
			
			self.checkForStoredCredentials(payload: formElements) { prefilled in
				if prefilled {
					self.sendAction(actionType: .submit)
				}
			}
		}
	}
	
	/// Function for setting up the constraints between the different views
	private func setupLayout() {
		let maxWidth: CGFloat = 500
		let sideSpacing = max((UIScreen.main.bounds.width - maxWidth) / 2, 20)
		
		var topPadding: CGFloat = 0
		if modalPresentationStyle == .pageSheet {
			topPadding = 20
		}
		
		if (withScrollView) {
			NSLayoutConstraint.activate([
				contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
				contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
				contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
				contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
				contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
				scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
				scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
				scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
				scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
			]);
		}
			
		NSLayoutConstraint.activate([
			stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: topPadding),
			stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: withScrollView ? -50 : 0),
			stackView.widthAnchor.constraint(lessThanOrEqualToConstant: maxWidth),
			stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: sideSpacing),
			stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -sideSpacing),
		])
	}
	
	/// Function for serializing the current form
	private func serializeForm() -> Dictionary<String, Any> {
		var payload: Dictionary<String, Any> = [:]
		for child in self.children {
			if child.view.isHidden {
				continue
			}
			

			let hasExposableFields = child as? ExposableFormElement
			if hasExposableFields != nil {
				let exposedClass = child as! ExposableFormElement
				let fields = exposedClass.exposableFields()
				if let fields = fields {
					payload.merge(fields){ (val, _) in val }
				}
			}
		}

		return payload
	}
	
	/**
	 Method for finding the next textfield (responder)
	 - Parameters:
	   - index: The index of the form element class of the textfield calling this method
	   - textField: The textfield calling this method
	*/
	func findNextResponder(index: Int, textField: UITextField) -> Bool {
		textField.resignFirstResponder()

		for (classIndex, instantiatedClass) in self.children.enumerated() {
			if classIndex <= index {
				// we can skip form elements that are above the form element that calls this function
				continue
			}

			let asTextLine 		= instantiatedClass as? TextLine
			let asPasswordLine 	= instantiatedClass as? PasswordLine
			let asCaptchaLine 	= instantiatedClass as? CaptchaLine
			let asFlickerLine 	= instantiatedClass as? FlickerLine
			
			if asTextLine != nil {
				asTextLine?.textfieldElement.becomeFirstResponder()
				break
			} else if asPasswordLine != nil {
				asPasswordLine?.textfieldElement.becomeFirstResponder()
				break
			} else if asCaptchaLine != nil {
				asCaptchaLine?.textfieldElement.becomeFirstResponder()
				break
			} else if asFlickerLine != nil {
				asFlickerLine?.textfieldElement.becomeFirstResponder()
				break
			}
		}

		return true
	}
	
	func cancelNetworkTask() {
		ApiService.cancelTask()
		isBusy = false
	}
	
	func disableInputs() {
		self.children.forEach { child in
			let asExposableElement = child as? ExposableFormElement
			if asExposableElement != nil {
				let exposedClass = child as! ExposableFormElement
				exposedClass.styleDisabled()
			}
		}
	}

	/**
	 First function called after a button is pressed
	 Delegates any further action like validation & serialization
	 - Parameters:
	   - actionType: The actionType represents the different button types (submit/back/abort/...)
	   - withLoadingIndicator: If a loading animation should be shown
	   - additionalPayload: Sometimes the calling class will have additional payload to send
	*/
	func sendAction(actionType: XS2AButtonType, withLoadingIndicator: Bool = true, additionalPayload: Dictionary<String, Any>? = [:]) {
		if isBusy {
			return
		}

		isBusy = true
		
		disableInputs()

		if withLoadingIndicator {
			showLoadingIndicator()
		}

		switch actionType {
		case .restart:
			handleFormSubmit(action: "restart")
		case .switch_login_tabs:
			handleFormSubmit(action: "switch-login-tabs", additionalPayload: additionalPayload)
		case .abort:
			result = .failure(.userAborted)
			dismissAndComplete();

			isBusy = false
		case .submit:
			handleFormSubmit(action: "submit")
		case .linkAutosubmit:
			handleFormSubmit(action: "submit", additionalPayload: additionalPayload)
		case .autosubmit:
			handleFormSubmit(action: "autosubmit")
		case .back:
			XS2A.shared.configuration.backButtonAction()
			handleFormSubmit(action: "back")
		case .redirect:
			handleFormSubmit(action: "post-code")
		case .none:
			handleFormSubmit(action: nil)
		default:
			isBusy = false
			return
		}
	}
	
	private func checkForKeychainItemExistence(itemName: String, completion: @escaping (Bool) -> Void) {
		// We spcify kSecUseAuthenticationUIFail so that the error
		// errSecInteractionNotAllowed will be returned if an item needs
		// to authenticate with UI and the authentication UI will not be presented.
		let keychainQuery: [AnyHashable: Any] = [
			kSecClass as AnyHashable: kSecClassGenericPassword,
			kSecAttrService as AnyHashable: "\(String(describing: Bundle.main.bundleIdentifier))_XS2A",
			kSecAttrAccount as AnyHashable: itemName,
			kSecUseAuthenticationUI as AnyHashable: kSecUseAuthenticationUIFail
		]
		
		var result: AnyObject?
		let status = SecItemCopyMatching(keychainQuery as CFDictionary, &result)

		// If that status is errSecInteractionNotAllowed, then
		// we know that the key is present, but you cannot interact with
		// it without authentication. Otherwise, we assume the key is not present.
		completion(status == errSecInteractionNotAllowed || status == errSecSuccess)
	}
	
	private func getKeychainItem(itemName: String, completion: (String?) -> Void) {
		do {
			let item = try XS2A.shared.keychain
				.authenticationPrompt("Authenticate to login to server")
				.authenticationContext(self.context)
				.get(itemName)

			completion(item)
		} catch _ {
			completion(nil)
		}
	}
	
	private func checkForStoredCredentials(payload: [FormLine], completion: @escaping (Bool) -> Void) {
		guard let provider = XS2A.shared.configuration.provider else {
			return completion(false)
		}

		var prefilled = false
		
		let firstLoginCredentialFormLine = payload.first { formLine in
			if let loginFormLine = formLine as? PotentialLoginCredentialFormLine {
				if loginFormLine.isLoginCredential {
					return true
				}
			}
			
			return false
		}
		
		var atLeastOneCredentialStored = false
		
		if let firstLoginCredentialFormLine = firstLoginCredentialFormLine {
			if let asLoginCredentialFormLine = firstLoginCredentialFormLine as? PotentialLoginCredentialFormLine {
				checkForKeychainItemExistence(itemName: "\(provider)_\(asLoginCredentialFormLine.name)") { credentialExists in
					atLeastOneCredentialStored = credentialExists
				}
			}
		} else {
			completion(false)
		}


		if atLeastOneCredentialStored {
			self.askToAutofill { shouldAutofill in
				if !shouldAutofill {
					completion(false)
				} else {
					let dispatchGroup = DispatchGroup()
					DispatchQueue.global().async {
						for formLine in payload {
							dispatchGroup.enter()

							if let loginCredentialLine = formLine as? PotentialLoginCredentialFormLine {
								self.getKeychainItem(itemName: "\(provider)_\(loginCredentialLine.name)") { (item) in
									if let loginCredentialItem = item {
										DispatchQueue.main.async {
											loginCredentialLine.setValue(value: loginCredentialItem)
											prefilled = true
										}
									}
								}
							}

							dispatchGroup.leave()
						}

						dispatchGroup.notify(queue: .main) {
							completion(prefilled)
						}
					}
				}
			}
		} else {
			completion(false)
		}
	}
	
	@available(iOS 11.3, *)
	private func storeCredentials(payload: Dictionary<String, Any>? = [:], completion: @escaping () -> Void) {
		guard let payload = payload else {
			return
		}

		guard let provider = XS2A.shared.configuration.provider else {
			return
		}

		
		var parametersToStore: Dictionary<String, String> = [:]
		
		for child in self.children {
			if let formLine = child as? PotentialLoginCredentialFormLine {
				if formLine.isLoginCredential {
					if let asString = payload[formLine.name] as? String {
						if (asString.count > 0) {
							parametersToStore["\(provider)_\(formLine.name)"] = asString
						}
					} else if let asBool = payload[formLine.name] as? Bool {
						parametersToStore["\(provider)_\(formLine.name)"] = String(asBool)
					}
				}
			}
		}

		if !parametersToStore.isEmpty {
			let dispatchGroup = DispatchGroup()

			DispatchQueue.global().async {
				parametersToStore.forEach { (key: String, value: String) in
					dispatchGroup.enter()

					do {
						try XS2A.shared.keychain
							.accessibility(.whenUnlockedThisDeviceOnly, authenticationPolicy: [.biometryAny])
							.authenticationContext(self.context)
							.set(value, key: key)
					} catch let error {
						print(error)
					}

					dispatchGroup.leave()
				}
				dispatchGroup.notify(queue: .main) {
					completion()
				}
			}
		} else {
			completion()
		}
	}
	
	/**
	 Function used for handling the submission of the form to the server
	 Delegates the different outcomes (e.g. setting up the next view or notifying the host app
	 - Parameters:
	   - payload: The payload to be send to the backend
	*/
	private func handleFormSubmit(action: String?, additionalPayload: Dictionary<String, Any>? = [:]) {
		var payload: Dictionary<String, Any> = [:]
		
		if (action != nil) {
			/**
			 Only if action is not nil, we serialize the form and send data.
			 */
			payload = serializeForm()

			if let additionalPayload = additionalPayload {
				payload.merge(additionalPayload){ (_, additional) in additional }
			}

			payload["action"] = action
		} else {
			/**
			 If no action is set, an empty request gets send, which will simply return the current state of the session.
			 */
			payload = [:]
		}
		
		// Check if store credentials notice checkbox is part of payload and is checked
		let storeCredentialsAccepted = payload.contains { (key, value) in
			return key == "store_credentials" && value as? String == "on"
		}
		
		if storeCredentialsAccepted {
			XS2A.shared.configuration.permissionToStoreCredentials = true
		}
		
		self.ApiService.postBody(payload: payload) { result in
			switch result {
			case .success(let formElements, let containsError):
				if containsError == false && XS2A.shared.configuration.permissionToStoreCredentials {
					if #available(iOS 11.3, *) {
						self.storeCredentials(payload: payload) {
							self.setupViews(formElements: formElements)
							self.isBusy = false
							
							return
						}
					}
				} else {
					self.setupViews(formElements: formElements)
					self.isBusy = false
					
					return
				}
			case .finish:
				self.result = .success(.finish)

				if XS2A.shared.configuration.permissionToStoreCredentials {
					if #available(iOS 11.3, *) {
						self.storeCredentials(payload: payload) {
							self.dismissAndComplete();
							self.isBusy = false
						}
					}
				} else {
					self.dismissAndComplete();
					self.isBusy = false
				}
			case .finishWithCredentials(let credentials):
				self.result = .success(.finishWithCredentials(credentials))
				self.dismissAndComplete();
				self.isBusy = false
			case .failure(_):
				self.result = .failure(.networkError)
				self.dismissAndComplete();
				self.isBusy = false
			}
		}
	}
	
	/// Completion handler for the final response from the backend
	private func completionHandler() {
		switch result {
		case .success(.finish):
			permanentCompletion?(.success(.finish))
		case .success(.finishWithCredentials(let credentials)):
			permanentCompletion?(.success(.finishWithCredentials(credentials)))
		case .failure(.userAborted):
			permanentCompletion?(.failure(.userAborted))
		case .failure(.networkError):
			permanentCompletion?(.failure(.networkError))
		case .some(.sessionError(_)):
			/// Session Errors don't complete a session and are not reported back here.
			return
		case .none:
			return
		}
	}
	
	func notifyOfSessionError(error: XS2ASessionError) {
		if let presentedViewController {
			presentedViewController.dismiss(animated: true) {
				self.permanentCompletion?(.sessionError(error))
			}
		} else {
			permanentCompletion?(.sessionError(error))
		}
	}
	
	/// Hides all UI Elements with an animation,
	/// then calls the completionHandler to notify the host app.
	private func dismissAndComplete() {
		hideElements {
			self.completionHandler()
		}
	}
	
	/// Delegation method for opening tappable Links
	func openLink(url: URL) {
		let urlString = "\(url)"
		if urlString.starts(with: "autosubmit::") {
			/// Link carries an autosubmit with query parameters
			/// We build a fake URL to make use of Swift's URL class for getting the query parameters
			let fakeUrl = URL(string: "https://xs2a.com/?\(urlString.components(separatedBy: "::")[1])")
			guard let payload = fakeUrl?.queryDictionary else {
				return
			}
			triggerHapticFeedback(style: .light)

			self.sendAction(actionType: .linkAutosubmit, withLoadingIndicator: true, additionalPayload: payload)
		} else if UIApplication.shared.canOpenURL(url) == true {
			let config = SFSafariViewController.Configuration()
			config.barCollapsingEnabled = false
			config.entersReaderIfAvailable = true
			let safariVC = SFSafariViewController(url: url, configuration: config)
			self.present(safariVC, animated: true, completion: nil)
		}
	}

	/// Looks for the SelectLine that contains the country_id and returns the selected value
	internal func getCountryId() -> String {
		// Set to DE as default
		var countryIdToReturn = "DE"

		for instantiatedClass in self.children {
			if instantiatedClass is SelectLine {
				let selectLineInstantiated = instantiatedClass as! SelectLine
				
				guard let selectedId = selectLineInstantiated.selectedElementId else {
					continue
				}

				countryIdToReturn = selectedId
				break
			}
		}
		
		return countryIdToReturn
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	/// Function that is called when the keyboard shows
	/// Increases the scrollView's bottom inset so user can scroll past the keyboard
	@objc func keyboardWillShow(notification: NSNotification) {
		guard let userInfo = notification.userInfo else {
			return
		}

		var keyboardFrame: CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
		keyboardFrame = self.view.convert(keyboardFrame, from: nil)

		var contentInset: UIEdgeInsets = self.scrollView.contentInset

		/// Increase the bottom inset by the height of the keyboard plus some margin
		contentInset.bottom = keyboardFrame.size.height + 20
		scrollView.contentInset = contentInset
	}

	/// Function called when the keyboard is hidden
	@objc func keyboardWillHide(notification: NSNotification) {
		/// Set back to regular inset
		scrollView.contentInset = .zero
	}

	/// Tells the server to go one step back and calls `backButtonAction` if supplied but only if a back button is present.
	public func goBack() {
		if !backButtonIsPresent { return }
		sendAction(actionType: .back, withLoadingIndicator: false, additionalPayload: nil)
	}

	/// Returns `true` if a back button is present on the current form.
	public var backButtonIsPresent: Bool {
		XS2A.shared.backButtonIsPresent
	}
	
	/// Returns `true` if the current form is the bank search, `false` otherwise
	public func isBankSearch() -> Bool {
		return XS2A.shared.currentState == "bank"
	}

	/// Returns `true` if the current form is the first login screen, `false` otherwise
	public func isLogin() -> Bool {
		return XS2A.shared.currentState == "login"
	}

	/// Function called when the user tries to dismiss this ViewController
	public func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
		showAbortAlert()
	}
	
	/// Function that disables the dismissing of this ViewController (didAttempt above will still be called)
	public func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
		return false
	}
	
	/// Let's the host app manually send a `redirect` action to advance the session. Used for app-to-app flows after coming back to the host app.
	public func submitRedirect() -> Void {
		sendAction(actionType: .redirect, withLoadingIndicator: true, additionalPayload: nil)
	}
	
	/// Function for showing an abort alert when user tries to leave this view
	private func showAbortAlert() {
		let alert = UIAlertController(
			title: Strings.Alert.Abort.title,
			message: Strings.Alert.Abort.message,
			preferredStyle: .alert
		)
		
		alert.addAction(
			UIAlertAction(
				title: Strings.no,
				style: .default,
				handler: { action in
					alert.dismiss(animated: true, completion: nil)
				}
			)
		)
		
		alert.addAction(
			UIAlertAction(
				title: Strings.yes,
				style: .cancel,
				handler: { action in
					self.result = .failure(.userAborted)
					self.dismissAndComplete();
				}
			)
		)
		
		self.present(alert, animated: true, completion: nil)
	}
	
	private func askToAutofill(completion: @escaping (Bool) -> Void) {
		let alert = UIAlertController(
			title: Strings.AutofillQuestion.title,
			message: Strings.AutofillQuestion.text,
			preferredStyle: .alert
		)
		
		alert.addAction(
			UIAlertAction(
				title: Strings.no,
				style: .default,
				handler: { action in
					alert.dismiss(animated: true, completion: nil)
					
					completion(false)
				}
			)
		)
		
		alert.addAction(
			UIAlertAction(
				title: Strings.yes,
				style: .cancel,
				handler: { action in
					alert.dismiss(animated: true, completion: nil)
					
					completion(true)
				}
			)
		)
		
		self.present(alert, animated: true, completion: nil)
	}
	
	@available(iOS 12.0, *)
	func setupNetworkStatusMonitor() {
		let networkMonitor = NWPathMonitor()
		networkMonitor.pathUpdateHandler = { [self] path in
			if path.status == .satisfied {
				if (!networkConnected) {
					networkConnected = true
					DispatchQueue.main.async {
						self.hideLoadingIndicator()
						self.sendAction(actionType: .none, withLoadingIndicator: false, additionalPayload: nil)
					}
				}
			} else {
				if (networkConnected) {
					networkConnected = false
					DispatchQueue.main.async {
						self.showLoadingIndicator(title: Strings.OfflineNotice.title, message: "\(Strings.OfflineNotice.text)\n\n\n")
						self.cancelNetworkTask()
					}
				}
			}
		}

		let queue = DispatchQueue(label: "NetworkMonitor")
		networkMonitor.start(queue: queue)
	}
	
	public override func viewDidLoad() {
		super.viewDidLoad()

		presentationController?.delegate = self
		
		if #available(iOS 12.0, *) {
			setupNetworkStatusMonitor()
		}

		/// We add an empty view because of buggy stackview animations
		let blankView = UIView()
		blankView.tag = 999

		stackView.addArrangedSubview(blankView)

		contentView.addSubview(stackView)
		
		if (withScrollView) {
			scrollView.addSubview(contentView)
			view.addSubview(scrollView)
		} else {
			view.addSubview(contentView)
			
			NSLayoutConstraint.activate([
				contentView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
				contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
				contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
			])
		}

		setupLayout()

		// From iOS 13 onwards Dark-Mode is available
		// We ignore it because we have styles provided by the StyleProvider
		if #available(iOS 13.0, *) {
			overrideUserInterfaceStyle = .light
		}
		
		// Override the navigation bar appearance from iOS 15
		if #available(iOS 15.0, *) {
			let navigationBarAppearance = UINavigationBarAppearance()
			navigationBarAppearance.configureWithDefaultBackground()

			navigationController?.navigationBar.standardAppearance = navigationBarAppearance
			navigationController?.navigationBar.compactAppearance = navigationBarAppearance
			navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
		}

		self.view.backgroundColor = XS2A.shared.styleProvider.backgroundColor

		self.hideKeyboardWhenTappedAround()
		
		// Observers for Keyboard Hide/Show
		// Will adjust the ScrollView Container Height
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
		

		self.ApiService.initCall(completion: { result in
			switch result {
			case .success(let formElements, _):
				self.setupViews(formElements: formElements)
				
				return
			case .finish:
				self.result = .success(.finish)
			case .finishWithCredentials(let credentials):
				self.result = .success(.finishWithCredentials(credentials))
			case .failure(_):
				self.result = .failure(.networkError)
			}
			
			self.dismissAndComplete();
		})
	}
}

/// Extension used for dismissing the keyboard when tapped on the view
extension UIViewController {
	func hideKeyboardWhenTappedAround() {
		let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
		tap.cancelsTouchesInView = false
		view.addGestureRecognizer(tap)
	}
	
	@objc func dismissKeyboard() {
		view.endEditing(true)
	}
}
