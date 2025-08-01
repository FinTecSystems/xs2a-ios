import UIKit

/// Protocol for communication between AutocompleteView and this TextLine
protocol NotificationDelegate {
	/// Called by AutocompleteView after a value has been selected there
	func notifyWithSelectedBank(selectedBank: String)
}

protocol TextfieldParentDelegate {
 	func shouldBeginEditing() -> Bool
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
	func textFieldDidEndEditing(_ textField: UITextField)
}

class TextLine: UIViewController, FormLine, ExposableFormElement, NotificationDelegate, TextfieldParentDelegate, PotentialLoginCredentialFormLine, ErrorableFormLine {
	var actionDelegate: ActionDelegate?
	
	internal let name: String
	private let label: String
    private let placeholder: String
	private let autocompleteAction: String?
    private let isRequired: Bool
    internal let invalid: Bool
    internal let errorMessage: String?
	let index: Int
	let isLoginCredential: Bool

	private let labelElement = UILabel.make(size: .large)
	let textfieldElement: XS2ATextfield
    let subTextContainer: SubTextContainer
	
	/**
	 - Parameters:
	   - name: The name of this text line
	   - label: The label of this text line
	   - disabled: Boolean indicating whether the text field is disabled
	   - invalid: Boolean indicating whether the text field is invalid
	   - autocompleteAction: String used in case this field is autocompleted
	   - value: A prefilled value for this text field
	   - placeholder: The placeholder for this text field
	   - index: Index of this element relative to all other input fields in the current parent view. Used for finding next responder.
	   - isLoginCredential: If this field is a login credential
       - isRequired: If this field is required
       - errorMessage: If this field contains a validation error
	*/
    init(name: String, label: String, disabled: Bool, invalid: Bool, autocompleteAction: String?, value: String, placeholder: String, index: Int, isLoginCredential: Bool, isRequired: Bool, errorMessage: String?) {
		self.name = name
		self.label = label
        self.placeholder = placeholder
        self.labelElement.text = label + (isRequired ? "*" : "")
        self.autocompleteAction = autocompleteAction
		self.index = index
		self.isLoginCredential = isLoginCredential
        self.invalid = invalid
        self.isRequired = isRequired
        self.errorMessage = errorMessage
				
		if self.autocompleteAction?.isEmpty == false {
			textfieldElement = TriggerTextfield()
		} else {
			textfieldElement = Textfield()
		}
        
        subTextContainer = SubTextContainer(contentView: textfieldElement)
        
        if (invalid) {
            subTextContainer.showMessage(errorMessage, isError: true)
        } else if (isRequired) {
            subTextContainer.showMessage(getStringForKey(key: "Input.Required"), isError: false, prefix: "*")
        }
		
		textfieldElement.text = value
		textfieldElement.attributedPlaceholder = NSAttributedString(
			string: placeholder,
			attributes: [NSAttributedString.Key.foregroundColor: XS2A.shared.styleProvider.placeholderColor]
		)

		if disabled {
			textfieldElement.isUserInteractionEnabled = false
			
			textfieldElement.backgroundColor = textfieldElement.backgroundColor?.darker()
		}
		
		if invalid {
			textfieldElement.styleTextfield(style: .error)
		}
		
		textfieldElement.autocorrectionType = .no
		textfieldElement.autocapitalizationType = .none
		textfieldElement.spellCheckingType = .no
		/// This will prevent the possible insertion of an (unwanted) extra space when performing a paste operation
		textfieldElement.smartInsertDeleteType = .no
		
		if (name.lowercased().contains("tan")) {
			/// Indicates this textfield is used for SMS one time codes.
			if #available(iOS 12.0, *) {
				textfieldElement.textContentType = .oneTimeCode
			}
		}
		
		super.init(nibName: nil, bundle: nil)
		textfieldElement.parentDelegate = self
	}
	
	func setValue(value: String) {
		textfieldElement.text = value
	}
	func styleDisabled() {
		self.textfieldElement.styleDisabledState()
	}
	
	func shouldBeginEditing() -> Bool {
		if self.autocompleteAction?.isEmpty == false {
			/// This TextLine is to be autocompleted
			let autocompleteVC = AutocompleteView(
				countryId: actionDelegate?.getCountryId() ?? "DE",
				label: self.label,
				prefilledText: self.textfieldElement.text
			)
			
			autocompleteVC.notificationDelegate = self
			self.present(autocompleteVC, animated: true, completion: nil)
			
			return false
		}
		
		return true
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		let shouldReturn = actionDelegate?.findNextResponder(index: self.index, textField: textField)

		return shouldReturn ?? false
	}
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateAccessibilityValue()
    }
	
	/// Called from AutocompleteView, lets us set the selected text
	func notifyWithSelectedBank(selectedBank: String) {
		textfieldElement.text = selectedBank
		textfieldElement.styleTextfield(style: .normal)
        updateAccessibilityValue()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
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
		var fieldPayload: Dictionary<String, Any> = [:]
		
		if name.isEmpty == false {
			/// sometimes name is empty
			fieldPayload[name] = textfieldElement.text ?? ""
		}
		
		if autocompleteAction != nil && autocompleteAction?.isEmpty == false {
			fieldPayload["action"] = autocompleteAction
		}
		
		return fieldPayload
	}
    
    private func setupAccessibility() {
        labelElement.isAccessibilityElement = false
        textfieldElement.isAccessibilityElement = false
        subTextContainer.isAccessibilityElement = false
        view.isAccessibilityElement = true
        view.accessibilityTraits = .none
        view.accessibilityLabel = "\(label). \(getStringForKey(key: "TextLine.Textfield"))"
        
        if (invalid) {
            view.accessibilityHint = "\(getStringForKey(key: "Input.Error")): \(errorMessage ?? "")"
        } else if (isRequired) {
            view.accessibilityHint = getStringForKey(key: "Input.Required")
        } else {
            view.accessibilityHint = nil
        }
        
        updateAccessibilityValue()
    }
    
    private func updateAccessibilityValue() {
        view.accessibilityValue = textfieldElement.text?.isEmpty == false ? textfieldElement.text : placeholder
    }
}
