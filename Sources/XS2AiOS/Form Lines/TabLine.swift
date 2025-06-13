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
        
        setupAccessibility()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
    
    private func setupAccessibility() {
        tabBtn.isAccessibilityElement = true
        tabBtn.accessibilityLabel = getStringForKey(key: "TabLine.Description")
        tabBtn.accessibilityHint = getStringForKey(key: "TabLine.Hint")
        tabBtn.accessibilityValue = tabBtn.titleForSegment(at: tabBtn.selectedSegmentIndex)
        tabBtn.accessibilityCustomActions = [
          UIAccessibilityCustomAction(
            name: getStringForKey(key: "TabLine.Next"),
            target: self,
            selector: #selector(accessibilityNextTab)
          ),
          UIAccessibilityCustomAction(
            name: getStringForKey(key: "TabLine.Previous"),
            target: self,
            selector: #selector(accessibilityPreviousTab)
          )
        ]
    }
    
    @objc private func accessibilityNextTab(_ action: UIAccessibilityCustomAction) -> Bool {
      let next = min(tabBtn.selectedSegmentIndex + 1, tabBtn.numberOfSegments - 1)
      guard next != tabBtn.selectedSegmentIndex else { return false }
      tabBtn.selectedSegmentIndex = next
      tabBtn.sendActions(for: .valueChanged)
      updateAccessibilityAnnouncement()
      return true
    }

    @objc private func accessibilityPreviousTab(_ action: UIAccessibilityCustomAction) -> Bool {
      let prev = max(tabBtn.selectedSegmentIndex - 1, 0)
      guard prev != tabBtn.selectedSegmentIndex else { return false }
      tabBtn.selectedSegmentIndex = prev
      tabBtn.sendActions(for: .valueChanged)
      updateAccessibilityAnnouncement()
      return true
    }

    // Helper to announce and refresh value
    private func updateAccessibilityAnnouncement() {
      let title = tabBtn.titleForSegment(at: tabBtn.selectedSegmentIndex) ?? ""
      tabBtn.accessibilityValue = title
      UIAccessibility.post(
        notification: .announcement,
        argument: "\(getStringForKey(key: "TabLine.Switched")) \(title)"
      )
    }
}
