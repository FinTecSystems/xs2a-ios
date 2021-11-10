import UIKit

class SelectLine: UIViewController, FormLine, ExposableFormElement, UIPickerViewDelegate, UIPickerViewDataSource {
	var actionDelegate: ActionDelegate?
	
	private var options: [(id: String, label: Any)] = []
	var selectedElementId: String? = nil
	
	private let label: String
	private let name: String
	let multiFormName: String?
	let multiFormValue: String?

	private let labelElement = UILabel.make(size: .large)
	private let pickerElement = UIPickerView()
	let textfieldElement = SelectTextfield()
	
	/**
	 - Parameters:
	   - options: The available options for this select line
	   - label: The label for this select line
	   - selected: The key of the (pre)selected option
	   - name: The name for this select line
	   - invalid: If this select is invalid
	   - multiFormName: The name of the multi form this element is part of (if any)
	   - multiFormValue: The value of the sub form this element is part of (if any)
	*/
	init(options: Dictionary<String, Any>, label: String, selected: String, name: String, invalid: Bool, multiFormName: String?, multiFormValue: String?) {
		/// Add default disabled row
		self.options.append((id: "disabled", label: Strings.choose))

		for (id, label) in options {
			self.options.append((id: id, label: label))
		}

		self.label = label
		self.selectedElementId = selected
		self.name = name
		self.multiFormName = multiFormName
		self.multiFormValue = multiFormValue
		
		if !selected.isEmpty {
			self.textfieldElement.text = options[selected] as? String
		} else {
			self.textfieldElement.attributedPlaceholder = NSAttributedString(
				string: Strings.choose,
				attributes: [NSAttributedString.Key.foregroundColor: XS2AiOS.shared.styleProvider.placeholderColor]
			)
		}
		
		labelElement.text = label
		
		if invalid {
			textfieldElement.styleTextfield(style: .error)
		}
		
		super.init(nibName: nil, bundle: nil)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		textfieldElement.inputView = pickerElement
		pickerElement.delegate = self
		pickerElement.dataSource = self

		/// In case we get a preselected value from the server, set the corresponding text
		if let selectedIndex = self.options.firstIndex(where: { $0.id == selectedElementId }) {
			textfieldElement.text = self.options[selectedIndex].label as? String
		}
		
		let stackView = UIStackView(arrangedSubviews: [labelElement, textfieldElement])
		stackView.setCustomSpacing(5, after: labelElement)
		stackView.axis = .vertical
		stackView.distribution = .fill
		stackView.translatesAutoresizingMaskIntoConstraints = false
		
		view.addSubview(stackView)

		NSLayoutConstraint.activate([
			stackView.topAnchor.constraint(equalTo: self.view.topAnchor),
			stackView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
			stackView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
			view.heightAnchor.constraint(equalTo: stackView.heightAnchor)
		])
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func exposableFields() -> Dictionary<String, Any>? {
		return [
			self.name: selectedElementId ?? ""
		]
	}
	
	func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
		if row == 0 {
			var attributes = [NSAttributedString.Key: AnyObject]()
			attributes[.foregroundColor] = UIColor.systemGray

			let attributedString = NSAttributedString(string: self.options[row].label as? String ?? Strings.choose, attributes: attributes)

			return attributedString
		}
		
		return NSAttributedString(string: self.options[row].label as! String)
	}
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return options.count
	}
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return options[row].label as? String
	}
	
	func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
		return false
	}
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		if row == 0 {
			/// If the first row ("Choose ...") row was selected, roll to next row
			pickerView.selectRow(1, inComponent: 0, animated: true)

			return
		}

		textfieldElement.text = options[row].label as? String
		selectedElementId = options[row].id
		textfieldElement.resignFirstResponder()
	}
}
