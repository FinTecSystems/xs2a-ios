import UIKit

class PasswordLine: UIViewController, FormLine, ExposableFormElement, TextfieldParentDelegate, PotentialLoginCredentialFormLine {
	var actionDelegate: ActionDelegate?
	
	let name: String
    private let label: String
	private let disabled: Bool?

    private let placeholder: String
    
    private let isRequired: Bool
    private let errorMessage: String?
    
	let index: Int
	let isLoginCredential: Bool

	private let labelElement = UILabel.make(size: .large)
	let textfieldElement = Textfield()
    let subTextContainer: SubTextContainer
	
	/**
	 - Parameters:
	   - name: The name of this password line
	   - label: The label of this password line
	   - disabled: Boolean indicating whether the input is disabled
	   - placeholder: Placeholder for the input
	   - invalid: If this element is invalid
	   - index: Index of this element relative to all other input fields in the current parent view. Used for finding next responder.
	   - isLoginCredential: If this field is a login credential
       - isRequired: If this field is required
       - errorMessage: If this field contains a validation error
	*/
	init(name: String, label: String, disabled: Bool, placeholder: String, invalid: Bool, index: Int, isLoginCredential: Bool, isRequired: Bool, errorMessage: String?) {
		self.name = name
        self.label = label
		self.labelElement.text = label
		self.disabled = disabled
        self.placeholder = placeholder
		self.index = index
		self.isLoginCredential = isLoginCredential
        self.isRequired = isRequired
        self.errorMessage = errorMessage
		self.textfieldElement.attributedPlaceholder = NSAttributedString(
			string: placeholder,
			attributes: [
				NSAttributedString.Key.foregroundColor: XS2A.shared.styleProvider.placeholderColor
			]
		)
        subTextContainer = SubTextContainer(contentView: textfieldElement)
        if (isRequired) {
            // TODO: Show error if applicable
            subTextContainer.showMessage(getStringForKey(key: "Input.Required"), isError: false)
        }
		
		super.init(nibName: nil, bundle: nil)

		textfieldElement.isSecureTextEntry = true
		textfieldElement.parentDelegate = self
		
		if invalid {
			textfieldElement.styleTextfield(style: .error)
		}
		
		if (XS2A.shared.configuration.showPasswordVisiblityToggle) {
			setPasswordToggleButton(eyeOpened: true)
		}
	}
	
	func setPasswordToggleButton(eyeOpened: Bool) {
		let background = UIImage(named: eyeOpened ? "eye_opened" : "eye_closed", in: .images, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
		let button = UIButton(type: .custom)
		button.tintColor = XS2A.shared.styleProvider.placeholderColor
		button.setImage(background, for: .normal)
		button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
		button.frame = CGRect(x: CGFloat(self.textfieldElement.frame.size.width - 20), y: CGFloat(5), width: CGFloat(30), height: CGFloat(30))
		button.addTarget(self, action: #selector(self.togglePassword), for: .touchUpInside)
		self.textfieldElement.rightView = button
		self.textfieldElement.rightViewMode = .always
	}
	
	@objc func togglePassword() {
		triggerHapticFeedback(style: .light)
		self.textfieldElement.isSecureTextEntry.toggle()
		
		if (!self.textfieldElement.isSecureTextEntry) {
			setPasswordToggleButton(eyeOpened: false)
		} else {
			setPasswordToggleButton(eyeOpened: true)
		}
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func shouldBeginEditing() -> Bool {
		return true
	}
	
	func setValue(value: String) {
		textfieldElement.text = value
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		let shouldReturn = actionDelegate?.findNextResponder(index: self.index, textField: textField)
		
		return shouldReturn ?? false
	}
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateAccessibilityValue()
    }
	
	override func viewDidLoad() {
		super.viewDidLoad()

        let stackView = UIStackView(arrangedSubviews: [labelElement, subTextContainer])
		stackView.addCustomSpacing(5, after: labelElement)
		stackView.axis = .vertical
		stackView.distribution = .fill

		view.addSubview(stackView)
		
		stackView.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			stackView.topAnchor.constraint(equalTo: self.view.topAnchor),
			stackView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
			stackView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
			view.heightAnchor.constraint(equalTo: stackView.heightAnchor)
		])
        
        setupAccessibility()
	}

	func exposableFields() -> Dictionary<String, Any>? {
		return [
			name: textfieldElement.text ?? "",
		]
	}
	
	func styleDisabled() {
		self.textfieldElement.styleDisabledState()
	}
    
    private func setupAccessibility() {
        labelElement.isAccessibilityElement = false
        textfieldElement.isAccessibilityElement = false
        subTextContainer.isAccessibilityElement = false
        view.isAccessibilityElement = true
        view.accessibilityTraits = .none
        view.accessibilityLabel = "\(label). \(getStringForKey(key: "PasswordLine.Textfield"))"
        updateAccessibilityValue()
        
        // Observe when VoiceOver focuses this element
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAccessibilityFocus(_:)),
            name: UIAccessibility.elementFocusedNotification,
            object: nil
        )
    }
    
    private func updateAccessibilityValue() {
        let textFieldValue = textfieldElement.isSecureTextEntry
            ? getStringForKey(key: "PasswordLine.Textfield.ValueHidden")
            : textfieldElement.text
        // TODO: Implement validation error / required message
        
        view.accessibilityValue = textfieldElement.text?.isEmpty == false ? textFieldValue : placeholder
    }
    
    @objc private func handleAccessibilityFocus(_ notification: Notification) {
        guard let focused = notification.userInfo?[UIAccessibility.focusedElementUserInfoKey] as? UIView else {
             return
         }
         if focused === view {
             // When this view is focused, activate the text field
             textfieldElement.becomeFirstResponder()
         } else {
             // Lose focus (resign) when moving away
             if textfieldElement.isFirstResponder {
                 textfieldElement.resignFirstResponder()
             }
         }
    }
}
