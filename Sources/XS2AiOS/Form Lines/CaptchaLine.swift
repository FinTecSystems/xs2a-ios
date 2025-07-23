import UIKit

class CaptchaLine: UIViewController, FormLine, ExposableFormElement, UITextFieldDelegate, TextfieldParentDelegate {
	var actionDelegate: ActionDelegate?
	
	internal let name: String
	let index: Int

	private var imageElement: UIImage
	private var imageViewElement: UIImageView
	private let labelElement = UILabel.make(size: .large)
	let textfieldElement = Textfield()
    let subTextContainer: SubTextContainer
	
    private let placeholder: String
    private let invalid: Bool
    private let label: String
    private let isRequired: Bool
    private let errorMessage: String?
    
	/**
	 - Parameters:
	   - name: The name of the captcha line
	   - label: The text for the label
	   - imageData: The base64 encoded image data
	   - placeholder: The placeholder for the input field
	   - invalid: If this element is invalid
	   - index: Index of this element relative to all other input fields in the current parent view. Used for finding next responder.
       - isRequired: If this field is required
       - errorMessage: If this field contains a validation error
	*/
	init(name: String, label: String, imageData: String, placeholder: String, invalid: Bool, index: Int, isRequired: Bool, errorMessage: String?) {
		self.name = name
		self.labelElement.text = label
		self.index = index
		self.textfieldElement.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor: XS2A.shared.styleProvider.placeholderColor])
        self.placeholder = placeholder
        self.invalid = invalid
        self.label = label
        self.isRequired = isRequired
        self.errorMessage = errorMessage
		imageElement = UIImage()
		imageViewElement = UIImageView()
        
        subTextContainer = SubTextContainer(contentView: textfieldElement)
        if (invalid) {
            subTextContainer.showMessage(errorMessage, isError: true)
        } else if (isRequired) {
            subTextContainer.showMessage(getStringForKey(key: "Input.Required"), isError: false, prefix: "*")
        }

		super.init(nibName: nil, bundle: nil)
		
		if let base64ImageData = imageForBase64String(imageData) {
			imageElement = base64ImageData
		}

		textfieldElement.parentDelegate = self
		
		if invalid {
			textfieldElement.styleTextfield(style: .error)
		}
	}
	
	
	func shouldBeginEditing() -> Bool {
		return true
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		let shouldReturn = actionDelegate?.findNextResponder(index: self.index, textField: textField)
		
		return shouldReturn ?? false
	}
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateAccessibilityValue()
    }
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		imageViewElement = UIImageView(image: imageElement)
		
		let stackView = UIStackView(arrangedSubviews: [labelElement, imageViewElement, subTextContainer])
		stackView.addCustomSpacing(5, after: labelElement)
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
        
        setupAccessibility()
	}

	func exposableFields() -> Dictionary<String, Any>? {
		return [
			name: textfieldElement.text ?? "",
		]
	}
	
	func styleDisabled() {
		self.textfieldElement.styleDisabledState()
	}

	
	private func styleTextfield(style: TextFieldStyles) {
		switch style {
		case .error:
			textfieldElement.layer.borderWidth = XS2A.shared.styleProvider.inputBorderWidthActive
			textfieldElement.layer.borderColor = XS2A.shared.styleProvider.errorStyle.backgroundColor.cgColor
			textfieldElement.layer.add(getBorderAnimation(type: .didStart), forKey: "Border")
		default:
			textfieldElement.layer.borderColor = XS2A.shared.styleProvider.inputBorderColor.cgColor
			textfieldElement.layer.borderWidth = XS2A.shared.styleProvider.inputBorderWidth
			textfieldElement.layer.add(getBorderAnimation(type: .didEnd), forKey: "Border")
		}
	}
    
    private func setupAccessibility() {
        view.isAccessibilityElement = true
        view.accessibilityLabel = labelElement.text
        labelElement.isAccessibilityElement = false
        subTextContainer.isAccessibilityElement = false
        textfieldElement.isAccessibilityElement = true
        view.accessibilityLabel = "\(label). \(getStringForKey(key: "TextLine.Textfield"))"
        
        if (invalid) {
            view.accessibilityHint = "\(getStringForKey(key: "Input.Error")): \(errorMessage ?? "")"
        } else if (isRequired) {
            view.accessibilityHint = getStringForKey(key: "Input.Required")
        } else {
            view.accessibilityHint = nil
        }
        
        updateAccessibilityValue()
        
        // Observe when VoiceOver focuses this element
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAccessibilityFocus(_:)),
            name: UIAccessibility.elementFocusedNotification,
            object: nil
        )
    }
    
    private func updateAccessibilityValue() {
        view.accessibilityValue = textfieldElement.text?.isEmpty == false ? textfieldElement.text : placeholder
    }
    
    @objc private func handleAccessibilityFocus(_ notification: Notification) {
      guard let focused = notification.userInfo?[UIAccessibility.focusedElementUserInfoKey] as? UIView else {
           return
       }
       if focused === view {
           // When this view is focused, activate the text field
           textfieldElement.becomeFirstResponder()
       } else {
           // Lose focus (resign) when moving away
           if textfieldElement.isFirstResponder {
               textfieldElement.resignFirstResponder()
           }
       }
    }
}
