import UIKit
import SwiftyJSON

class MultiFormController: UIViewController, FormLine, ExposableFormElement {
	var actionDelegate: ActionDelegate?
	
	/// There is no nested multiforms, so init with nil
	let multiFormName: String? = nil
	let multiFormValue: String? = nil
	
	/// Indicates the selected multiFormValue
	var selectedMultiFormValue: String

	/// The name of this MultiForm
	let name: String
	
	/// Array carrying the different MultiFormValues for this MultiForm (essentially the available options)
	private var multiFormValues: Array<String> = []
	
	/// A button controller instance
	private let radioController: RadioButtonController = RadioButtonController()
	
	/**
	 - Parameters:
	   - name: The name of this MultiForm
	   - selectedMultiFormValue: The (pre)selected value, indicating which sub-form should be shown
	   - forms: JSON array of sub-forms this MultiForm contains
	*/
	init(name: String, selectedMultiFormValue: String, forms: [JSON]) {
		self.name = name
		self.selectedMultiFormValue = selectedMultiFormValue
	
		super.init(nibName: nil, bundle: nil)
		
		var selectedButtonIndex: Int?
		
		/// Iterate over the sub-forms of this MultiForm
		for (index, subForm) in forms.enumerated() {
			/// We store the multiFormValue for this sub-form for later reference
			multiFormValues.append(subForm["value"].stringValue)

			/// Create a new radio button for every sub-form
			let radioBtn = RadioButton()
			radioBtn.setTitle(subForm["label"].string, for: .normal)
			radioBtn.tag = index
			radioBtn.setTitleColor(XS2AiOS.shared.styleProvider.textColor, for: .normal)

			/// Attach buttonTapped function to the radio button
			radioBtn.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
			
			/// Store the button for later reference
			radioController.buttonsArray.append(radioBtn)
			
			if selectedMultiFormValue == subForm["value"].stringValue {
				/// the current button is the selectedMultiFormValue for this MultiForm
				selectedButtonIndex = index
			}
		}

		/// Either preselect the button derived from selectedMultiFormValue or use the first
		radioController.defaultButton = radioController.buttonsArray[selectedButtonIndex ?? 0]
	}
	
	@objc func buttonTapped(sender: UIButton) {
		/// If the keyboard is still open, close it when an option is tapped
		view.superview?.endEditing(true)
		selectedMultiFormValue = multiFormValues[sender.tag]
		radioController.setSelectedButton(buttonSelected: radioController.buttonsArray[sender.tag])
		actionDelegate?.showMultiFormElements(withName: self.name, withValue: multiFormValues[sender.tag])
	}

	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	func setupViews() {
		view.subviews.forEach({ $0.removeFromSuperview() })
		
		let subviews: [UIView] = radioController.buttonsArray
		
		let stackView = UIStackView(arrangedSubviews: subviews)
		stackView.axis = .vertical
		stackView.distribution = .fill
		stackView.translatesAutoresizingMaskIntoConstraints = false
		
		view.addSubview(stackView)

		NSLayoutConstraint.activate([
			stackView.topAnchor.constraint(equalTo: self.view.topAnchor),
			stackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			stackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
			view.heightAnchor.constraint(equalTo: stackView.heightAnchor)
		])
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupViews()
	}

	func exposableFields() -> Dictionary<String, Any>? {
		return [
			name: selectedMultiFormValue
		]
	}
}
