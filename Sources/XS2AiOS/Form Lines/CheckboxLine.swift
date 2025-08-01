import UIKit

protocol OpenLinkDelegate {
	func openLink(url: URL)
}

class CheckboxLine: UIViewController, FormLine, ExposableFormElement, PotentialLoginCredentialFormLine, OpenLinkDelegate, ErrorableFormLine {
	var isLoginCredential: Bool
	
	var actionDelegate: ActionDelegate?
	
	/// The name of this checkbox line
	internal let name: String
	
	/// Boolean indicating whether the element is disabled
	private let disabled: Bool
    private let isRequired: Bool
    internal let invalid: Bool
    internal let errorMessage: String?
	
	let checkedImage = UIImage(named: "checkmark_ticked", in: .images, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
	let uncheckedImage = UIImage(named: "checkmark", in: .images, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
	let checkedDisabledImage = UIImage(named: "checkmark_ticked", in: .images, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
	let uncheckedDisabledImage = UIImage(named: "checkmark", in: .images, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)

	let button = UIButton()
	let labelElement: InteractiveLinkLabel = {
		let label = InteractiveLinkLabel()
		label.numberOfLines = 0
		label.adjustsFontSizeToFitWidth = true
		label.font = XS2A.shared.styleProvider.font.getFont(ofSize: 13, ofWeight: nil)
		label.textColor = XS2A.shared.styleProvider.textColor

		return label
	}()
    
    let subTextContainer: SubTextContainer
	
	func setValue(value: String) {
		checked = true
	}

	
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
	   - isLoginCredential: If this is a LoginCredential
       - invalid: Boolean indicating whether the text field is invalid
       - isRequired: If this field is required
       - errorMessage: If this field contains a validation error
	*/
    init(label: String, checked: Bool, name: String, disabled: Bool, isLoginCredential: Bool, invalid: Bool, isRequired: Bool, errorMessage: String?) {
		self.checked = checked
		self.name = name
        self.invalid = invalid
        self.isRequired = isRequired
        self.errorMessage = errorMessage
		
		let attributedString = constructLabelString(stringToTest: label)
		
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.alignment = NSTextAlignment.left
		attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
		
		labelElement.attributedText = attributedString
		labelElement.sizeToFit()
		
		button.tintColor = XS2A.shared.styleProvider.tintColor

		self.isLoginCredential = isLoginCredential
		self.disabled = disabled
		if disabled == true {
			button.isEnabled = false
			
			if checked == true {
				button.setImage(checkedDisabledImage, for: .normal)
			} else {
				button.setImage(uncheckedDisabledImage, for: .normal)
			}
		}
        
        subTextContainer =  SubTextContainer(contentView: labelElement)
        if (invalid) {
            subTextContainer.showMessage(errorMessage, isError: true)
        } else if (isRequired) {
            subTextContainer.showMessage(getStringForKey(key: "Input.Required"), isError: false, prefix: "*")
        }
		
		super.init(nibName: nil, bundle: nil)
		labelElement.openLinkDelegate = self
	}
	
	/// Function for opening in-app webview when links inside the checkbox' paragraph are tapped
	func openLink(url: URL) {
		actionDelegate?.openLink(url: url)
	}
	
	func exposableFields() -> Dictionary<String, Any>? {
		if (!checked) {
			return [:]
		}

		return [
			name: "on"
		]
	}
	
	func styleDisabled() {
		UIView.animate(withDuration: 0.1, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 1, options: .curveEaseOut) {
			self.button.tintColor = self.button.tintColor?.darker().darker()
		}
	}
	
	@objc func buttonTapped() {
		view.superview?.endEditing(true)
		triggerHapticFeedback(style: .light)
		checked = !checked
        
        setCheckedAccessibilityValue()
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
        
		let stackView = UIStackView(arrangedSubviews: [button, subTextContainer])
        stackView.addCustomSpacing(7, after: button)
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
        
        setupAccessibility()
	}
    
    private func setupAccessibility() {
        view.isAccessibilityElement = true
        labelElement.accessibilityTraits = []
        
        setCheckedAccessibilityValue()
        
        let stringDisabled = disabled ? getStringForKey(key: "CheckboxLine.Disabled") : ""

        // where is the required implementation?
        //        let stringRequired = required ? getStringForKey(key: "CheckboxLine.Required") : ""
        
        view.accessibilityLabel = "\(getStringForKey(key: "CheckboxLine.Checkbox")): \(stringDisabled). \(labelElement.text ?? "")"
        
        if (invalid) {
            view.accessibilityHint = "\(getStringForKey(key: "Input.Error")): \(errorMessage ?? "")"
        } else if (isRequired) {
            view.accessibilityHint = getStringForKey(key: "Input.Required")
        } else {
            view.accessibilityHint = nil
        }
    }
    
    private func setCheckedAccessibilityValue() {
        if checked {
            view.accessibilityValue = getStringForKey(key: "CheckboxLine.Selected")
        } else {
            view.accessibilityValue = ""
        }
    }
}
