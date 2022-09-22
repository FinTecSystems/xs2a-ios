import UIKit

class HiddenLine: UIViewController, FormLine, ExposableFormElement {
	var actionDelegate: ActionDelegate?

	internal let name: String
	private var value: String
	
	/**
	 - Parameters:
	   - name: The name of the hidden line
	   - value: Value of the hidden line
	*/
	init(name: String, value: String) {
		self.name = name
		self.value = value

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
