import UIKit
import SwiftyJSON

class RadioLine: UIViewController, FormLine, ExposableFormElement {
	var actionDelegate: ActionDelegate?
	
	private let name: String
	private var checked: Int
	
	let multiFormName: String?
	let multiFormValue: String?
	
	private let labelElement = UILabel.make(size: .large)
	private let radioController: RadioButtonController = RadioButtonController()
	
	/**
	 - Parameters:
	   - label: The label of this radio line
	   - checked: Integer indicating the (pre)checked radio option
	   - name: The name of this radio line
	   - options: Array of available radio options
	   - multiFormName: The name of the multi form this element is part of (if any)
	   - multiFormValue: The value of the sub form this element is part of (if any)
	*/
	init(label: String, checked: Int, name: String, options: [(label: String, disabled: Bool)], multiFormName: String?, multiFormValue: String?) {
		self.name = name
		self.checked = checked
		self.multiFormName = multiFormName
		self.multiFormValue = multiFormValue
		self.labelElement.text = label
		self.labelElement.numberOfLines = 0
		super.init(nibName: nil, bundle: nil)

		/// Iterate over all radio options
		for (index, option) in options.enumerated() {
			/// Create a new radio button for every radio option
			let radioBtn = RadioButton()
			radioBtn.translatesAutoresizingMaskIntoConstraints = false
			radioBtn.setTitle(option.label, for: .normal)
			radioBtn.tag = index
			radioBtn.titleLabel?.numberOfLines = 2
			radioBtn.titleLabel?.font = XS2AiOS.shared.styleProvider.font.getFont(ofSize: 14, ofWeight: nil)
			radioBtn.setTitleColor(XS2AiOS.shared.styleProvider.textColor, for: .normal)
			radioBtn.isEnabled = !option.disabled
			
			/// Attach buttonTapped function to the radio button
			radioBtn.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)

			/// Store the button for later reference
			radioController.buttonsArray.append(radioBtn)
		}
		
		/// Preselect the `checked` radio button by index (if available)
		if checked >= 0 && radioController.buttonsArray.count > checked {
			radioController.defaultButton = radioController.buttonsArray[checked]
		}
	}
	
	@objc func buttonTapped(sender: UIButton) {
		/// If the keyboard is still open, close it when a radio option is tapped
		view.superview?.endEditing(true)
		self.checked = sender.tag
		radioController.setSelectedButton(buttonSelected: radioController.buttonsArray[sender.tag])
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func exposableFields() -> Dictionary<String, Any>? {
		return [
			name: checked
		]
	}
	
	func styleDisabled() {
		// Nothing to style for Radios.
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let stackView = UIStackView(arrangedSubviews: [labelElement] + radioController.buttonsArray)
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
}
