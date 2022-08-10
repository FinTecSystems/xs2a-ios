import UIKit

class TabLine: UIViewController, FormLine {
	var actionDelegate: ActionDelegate?
	
	private let tabBtn = UISegmentedControl()
	private var tabOptions: Array<String> = []

	private let radioController: RadioButtonController = RadioButtonController()
	
	/**
	 - Parameters:
	   - selected: The (pre)selected tab value
	   - tabs: The available tab options
	*/
	init(selected: String, tabs: Dictionary<String, String>) {
		super.init(nibName: nil, bundle: nil)

		var index = 0

		for (key, value) in tabs {
			tabBtn.insertSegment(withTitle: value, at: index, animated: false)
			tabOptions.append(key)

			if key == selected {
				tabBtn.selectedSegmentIndex = index
			}

			index += 1
		}
		
		/// Attach selectedTabChanged function to the tab button
		tabBtn.addTarget(self, action: #selector(selectedTabChanged), for: .valueChanged)
	}
	
	@objc func selectedTabChanged(sender: UIButton) {
		let payload = [
			"params": tabOptions[tabBtn.selectedSegmentIndex]
		]

		actionDelegate?.sendAction(actionType: .switch_login_tabs, withLoadingIndicator: true, additionalPayload: payload)
	}
	
	override func viewDidLoad() {
		tabBtn.translatesAutoresizingMaskIntoConstraints = false

		view.addSubview(tabBtn)
		
		NSLayoutConstraint.activate([
			view.heightAnchor.constraint(equalTo: tabBtn.heightAnchor),
			tabBtn.widthAnchor.constraint(equalTo: view.widthAnchor),
		])
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
