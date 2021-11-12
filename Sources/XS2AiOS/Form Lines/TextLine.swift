import UIKit

/// Protocol for communication between AutocompleteView and this TextLine
protocol NotificationDelegate {
	/// Called by AutocompleteView after a value has been selected there
	func notifyWithSelectedBank(selectedBank: String)
}

protocol TextfieldParentDelegate {
 	func shouldBeginEditing() -> Bool
	func textFieldShouldReturn(_ textField: UITextField) -> Bool
}

class TextLine: UIViewController, FormLine, ExposableFormElement, NotificationDelegate, TextfieldParentDelegate, LoginCredentialFormLine {
	var actionDelegate: ActionDelegate?
	
	let name: String
	private let label: String
	private let autocompleteAction: String?
	let index: Int
	let isLoginCredential: Bool
	let multiFormName: String?
	let multiFormValue: String?

	private let labelElement = UILabel.make(size: .large)
	let textfieldElement = Textfield()
	
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
	   - multiFormName: The name of the multi form this element is part of (if any)
	   - multiFormValue: The value of the sub form this element is part of (if any)
	*/
	init(name: String, label: String, disabled: Bool, invalid: Bool, autocompleteAction: String?, value: String, placeholder: String, index: Int, isLoginCredential: Bool, multiFormName: String?, multiFormValue: String?) {
		self.name = name
		self.label = label
		self.labelElement.text = label
		self.autocompleteAction = autocompleteAction
		self.index = index
		self.isLoginCredential = isLoginCredential
		self.multiFormName = multiFormName
		self.multiFormValue = multiFormValue
		
		textfieldElement.text = value
		textfieldElement.attributedPlaceholder = NSAttributedString(
			string: placeholder,
			attributes: [NSAttributedString.Key.foregroundColor: XS2AiOS.shared.styleProvider.placeholderColor]
		)

		if disabled {
			textfieldElement.isUserInteractionEnabled = false
			
			/// Equal to .systemGray4
			textfieldElement.backgroundColor = UIColor(red: 0.8196078431372549, green: 0.8196078431372549, blue: 0.8392156862745098, alpha: 1.0)
		}
		
		if invalid {
			textfieldElement.styleTextfield(style: .error)
		}
		
		textfieldElement.autocorrectionType = .no
		textfieldElement.autocapitalizationType = .none
		textfieldElement.spellCheckingType = .no
		/// This will prevent the possible insertion of an (unwanted) extra space when performing a paste operation
		textfieldElement.smartInsertDeleteType = .no
		
		super.init(nibName: nil, bundle: nil)
		textfieldElement.parentDelegate = self
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
	
	/// Called from AutocompleteView, lets us set the selected text
	func notifyWithSelectedBank(selectedBank: String) {
		textfieldElement.text = selectedBank
		textfieldElement.styleTextfield(style: .normal)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let stackView = UIStackView(arrangedSubviews: [labelElement, textfieldElement])
		stackView.setCustomSpacing(5, after: labelElement)
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
}
