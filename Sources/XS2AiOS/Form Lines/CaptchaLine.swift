import UIKit

class CaptchaLine: UIViewController, FormLine, ExposableFormElement, UITextFieldDelegate, TextfieldParentDelegate {
	var actionDelegate: ActionDelegate?
	
	internal let name: String
	let index: Int

	private var imageElement: UIImage
	private var imageViewElement: UIImageView
	private let labelElement = UILabel.make(size: .large)
	let textfieldElement = Textfield()
	
	/**
	 - Parameters:
	   - name: The name of the captcha line
	   - label: The text for the label
	   - imageData: The base64 encoded image data
	   - placeholder: The placeholder for the input field
	   - invalid: If this element is invalid
	   - index: Index of this element relative to all other input fields in the current parent view. Used for finding next responder.
	*/
	init(name: String, label: String, imageData: String, placeholder: String, invalid: Bool, index: Int) {
		self.name = name
		self.labelElement.text = label
		self.index = index
		self.textfieldElement.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor: XS2AiOS.shared.styleProvider.placeholderColor])
		imageElement = UIImage()
		imageViewElement = UIImageView()

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
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		imageViewElement = UIImageView(image: imageElement)
		
		let stackView = UIStackView(arrangedSubviews: [labelElement, imageViewElement, textfieldElement])
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
			textfieldElement.layer.borderWidth = XS2AiOS.shared.styleProvider.inputBorderWidthActive
			textfieldElement.layer.borderColor = XS2AiOS.shared.styleProvider.errorStyle.backgroundColor.cgColor
			textfieldElement.layer.add(getBorderAnimation(type: .didStart), forKey: "Border")
		default:
			textfieldElement.layer.borderColor = XS2AiOS.shared.styleProvider.inputBorderColor.cgColor
			textfieldElement.layer.borderWidth = XS2AiOS.shared.styleProvider.inputBorderWidth
			textfieldElement.layer.add(getBorderAnimation(type: .didEnd), forKey: "Border")
		}
	}
}
