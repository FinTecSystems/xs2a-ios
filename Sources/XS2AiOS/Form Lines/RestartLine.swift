import UIKit

class RestartLine: UIViewController, FormLine {
	var actionDelegate: ActionDelegate?
	
	private let button: UIButton
	
	/**
	 - Parameters:
	   - label: The button text of this restart line
	*/
	init(label: String) {
		button = UIButton.make(buttonType: .restart)
		button.setTitle(label, for: .normal)

		super.init(nibName: nil, bundle: nil)
		
		/// Attach buttonTapped function to the button
		button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
	}
	
	@objc func buttonTapped() {
		/// If the keyboard is still open, close it
		view.superview?.endEditing(true)

		triggerHapticFeedback(style: .light)
		actionDelegate?.sendAction(actionType: .restart, withLoadingIndicator: true, additionalPayload: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()

		view.addSubview(button)
		
		NSLayoutConstraint.activate([
			view.heightAnchor.constraint(equalTo: button.heightAnchor),
			button.widthAnchor.constraint(equalTo: view.widthAnchor),
		])
	}
}
