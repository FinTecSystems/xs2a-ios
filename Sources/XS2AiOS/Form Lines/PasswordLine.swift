import UIKit

class PasswordLine: UIViewController, FormLine, ExposableFormElement, TextfieldParentDelegate, PotentialLoginCredentialFormLine {
	var actionDelegate: ActionDelegate?
	
	let name: String
	private let disabled: Bool?

	let index: Int
	let isLoginCredential: Bool
	let multiFormName: String?
	let multiFormValue: String?

	private let labelElement = UILabel.make(size: .large)
	let textfieldElement = Textfield()
	
	/**
	 - Parameters:
	   - name: The name of this password line
	   - label: The label of this password line
	   - disabled: Boolean indicating whether the input is disabled
	   - placeholder: Placeholder for the input
	   - invalid: If this element is invalid
	   - index: Index of this element relative to all other input fields in the current parent view. Used for finding next responder.
	   - isLoginCredential: If this field is a login credential
	   - multiFormName: The name of the multi form this element is part of (if any)
	   - multiFormValue: The value of the sub form this element is part of (if any)
	*/
	init(name: String, label: String, disabled: Bool, placeholder: String, invalid: Bool, index: Int, isLoginCredential: Bool, multiFormName: String?, multiFormValue: String?) {
		self.name = name
		self.labelElement.text = label
		self.disabled = disabled
		self.index = index
		self.isLoginCredential = isLoginCredential
		self.textfieldElement.attributedPlaceholder = NSAttributedString(
			string: placeholder,
			attributes: [
				NSAttributedString.Key.foregroundColor: XS2AiOS.shared.styleProvider.placeholderColor
			]
		)
		self.multiFormName = multiFormName
		self.multiFormValue = multiFormValue
		
		super.init(nibName: nil, bundle: nil)

		textfieldElement.isSecureTextEntry = true
		textfieldElement.parentDelegate = self
		
		if invalid {
			textfieldElement.styleTextfield(style: .error)
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
	
	override func viewDidLoad() {
		super.viewDidLoad()

		let stackView = UIStackView(arrangedSubviews: [labelElement, textfieldElement])
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
	}

	func exposableFields() -> Dictionary<String, Any>? {
		return [
			name: textfieldElement.text ?? "",
		]
	}
	
	func styleDisabled() {
		self.textfieldElement.styleDisabledState()
	}
}
