import UIKit

class HiddenLine: UIViewController, FormLine, ExposableFormElement {
	var actionDelegate: ActionDelegate?

	internal let name: String
	private var value: String

	let multiFormName: String?
	let multiFormValue: String?
	
	/**
	 - Parameters:
	   - name: The name of the hidden line
	   - value: Value of the hidden line
	   - multiFormName: The name of the multi form this element is part of (if any)
	   - multiFormValue: The value of the sub form this element is part of (if any)
	*/
	init(name: String, value: String, multiFormName: String?, multiFormValue: String?) {
		self.name = name
		self.value = value
		self.multiFormName = multiFormName
		self.multiFormValue = multiFormValue
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func exposableFields() -> Dictionary<String, Any>? {
		return [name: value]
	}
	
	func styleDisabled() {
		// Nothing to do here, it's not visible.
	}
}
