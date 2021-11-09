import UIKit
import SafariServices

protocol OpenLinkDelegate {
	func openLink(url: URL)
	func openAlert(content: String)
}

class CheckboxLine: UIViewController, FormLine, ExposableFormElement, OpenLinkDelegate {
	var actionDelegate: ActionDelegate?
	
	/// The name of this checkbox line
	private let name: String
	
	/// Boolean indicating whether the element is disabled
	private let disabled: Bool

	let multiFormName: String?
	let multiFormValue: String?
	
	let checkedImage = UIImage(named: "checkmark_ticked", in: .current, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
	let uncheckedImage = UIImage(named: "checkmark", in: .current, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
	let checkedDisabledImage = UIImage(named: "checkmark_ticked", in: .current, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
	let uncheckedDisabledImage = UIImage(named: "checkmark", in: .current, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)

	let button = UIButton()
	let labelElement: InteractiveLinkLabel = {
		let label = InteractiveLinkLabel()
		label.numberOfLines = 0
		label.adjustsFontSizeToFitWidth = true
		label.font = XS2AiOS.shared.styleProvider.font.getFont(ofSize: 13, ofWeight: nil)
		label.textColor = XS2AiOS.shared.styleProvider.textColor

		return label
	}()

	
	var checked: Bool = false {
		didSet {
			UIView.transition(with: button, duration: 0.1, options: .transitionCrossDissolve) {
				if self.checked == true {
					self.button.setImage(self.checkedImage, for: UIControl.State.normal)
				} else {
					self.button.setImage(self.uncheckedImage, for: UIControl.State.normal)
				}
			}
		}
	}
	
	/**
	 - Parameters:
	   - label: The text for the label
	   - checked: Boolean indicating whether the checkbox is checked
	   - name: The name of the checkbox line
	   - disabled: Boolean indicating whether the element is disabled (if true, `checked` can not be changed)
	   - multiFormName: The name of the multi form this element is part of (if any)
	   - multiFormValue: The value of the sub form this element is part of (if any)
	*/
	init(label: String, checked: Bool, name: String, disabled: Bool, multiFormName: String?, multiFormValue: String?) {
		self.multiFormName = multiFormName
		self.multiFormValue = multiFormValue
		self.checked = checked
		self.name = name
		
		let attributedString = constructLabelString(stringToTest: label)
		
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.alignment = NSTextAlignment.left
		attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
		
		labelElement.attributedText = attributedString
		labelElement.sizeToFit()
		
		button.tintColor = XS2AiOS.shared.styleProvider.tintColor

		
		self.disabled = disabled
		if disabled == true {
			button.isEnabled = false
			
			if checked == true {
				button.setImage(checkedDisabledImage, for: .normal)
			} else {
				button.setImage(uncheckedDisabledImage, for: .normal)
			}
		}
		
		super.init(nibName: nil, bundle: nil)
		labelElement.openLinkDelegate = self

	}
	
	/// Function for opening in-app webview when links inside the checkbox' paragraph are tapped
	func openLink(url: URL) {
		let config = SFSafariViewController.Configuration()
		config.barCollapsingEnabled = false
		config.entersReaderIfAvailable = true
		let safariVC = SFSafariViewController(url: url, configuration: config)
		self.present(safariVC, animated: true, completion: nil)
	}
	
	/// Function for opening notices inside the checkbox' paragraph
	func openAlert(content: String) {
		actionDelegate?.openAlert(content: content)
	}

	
	func exposableFields() -> Dictionary<String, Any>? {
		return [
			name: checked
		]
	}
	
	func validate() -> Bool {
		return true
	}

	
	@objc func buttonTapped() {
		view.superview?.endEditing(true)
		triggerHapticFeedback(style: .light)
		checked = !checked
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		if checked == true {
			button.setImage(checkedImage, for: UIControl.State.normal)
		} else {
			button.setImage(uncheckedImage, for: UIControl.State.normal)
		}
		

		if disabled == false {
			let labelTap = UITapGestureRecognizer(target: self, action: #selector(buttonTapped))
			labelElement.isUserInteractionEnabled = true
			labelElement.addGestureRecognizer(labelTap)
			button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
		}
		
		let stackView = UIStackView(arrangedSubviews: [button, labelElement])
		stackView.setCustomSpacing(7, after: button)
		stackView.axis = .horizontal
		
		stackView.alignment = .top
		stackView.distribution = .fill
		
		view.addSubview(stackView)
		
		stackView.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			button.heightAnchor.constraint(equalToConstant: 27),
			button.widthAnchor.constraint(equalToConstant: 27),
			stackView.topAnchor.constraint(equalTo: self.view.topAnchor),
			stackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			stackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
			view.heightAnchor.constraint(equalTo: stackView.heightAnchor)
		])
	}
}
