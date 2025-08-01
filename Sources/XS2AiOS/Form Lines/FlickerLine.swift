import UIKit

enum FlickerAlignment {
	case vertical
	case horizontal
}

class FlickerLine: UIViewController, FormLine, ExposableFormElement, TextfieldParentDelegate, ErrorableFormLine {
	var actionDelegate: ActionDelegate?
	
	internal let name: String
	private let index: Int
    private let placeholder: String
    private let isRequired: Bool
    internal let invalid: Bool
    internal let errorMessage: String?
	
	/**
	An array of arrays that contain 5 integers each, indicating on/white (1) or off/black (0) for the flickerContainers.
	Every time `step()` is called, we move to the next array.
	Example: `[[1, 0, 1, 0, 1],[0, 0, 1, 1, 0], ...]`
	*/
	private let code: Array<Array<Int>>

	var flickerContainer: [UIView] = []
	private var flickerAlignment: FlickerAlignment = .horizontal
	private var position: Int = 0
	private var timer = Timer()
	
	private var flickerStackView = UIStackView()
	private var flickerSizeAnchor: NSLayoutConstraint?
	private let labelElement = UILabel.make(size: .large)
	let textfieldElement = Textfield()
    let subTextContainer: SubTextContainer
	
	/**
	 - Parameters:
	   - name: The name of the flicker line
	   - code: Flicker data encoded in an array of arrays of integers, where 1 indicates on and 0 off
	   - label: The label for the input element
	   - invalid:If this element is invalid
	   - index: Index of this element relative to all other input fields in the current parent view. Used for finding next responder.
       - isRequired: If this field is required
       - errorMessage: If this field contains a validation error
	*/
    init(name: String, code: Array<Array<Int>>, label: String, invalid: Bool, index: Int, placeholder: String, isRequired: Bool, errorMessage: String?) {
		self.name = name
		self.code = code
		self.index = index
        self.placeholder = placeholder
        self.invalid = invalid
        self.isRequired = isRequired
        self.errorMessage = errorMessage

        subTextContainer = SubTextContainer(contentView: textfieldElement)
        if (invalid) {
            subTextContainer.showMessage(errorMessage, isError: true)
        } else if (isRequired) {
            subTextContainer.showMessage(getStringForKey(key: "Input.Required"), isError: false, prefix: "*")
        }
        
		labelElement.text = label + (isRequired ? "*" : "")
		super.init(nibName: nil, bundle: nil)
		
		textfieldElement.parentDelegate = self
		
		if invalid {
			textfieldElement.styleTextfield(style: .error)
		}
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
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
	
	/// Function for stepping through the code array and 'flickering' between white and black
	@objc private func step() {
		let currentCode = code[position]
		position += 1

		if position >= code.count {
			position = 0
		}

		for (index, flickerValue) in currentCode.enumerated() {
			if flickerValue == 1 {
				flickerContainer[index].backgroundColor = .white
			} else {
				flickerContainer[index].backgroundColor = .black
			}
		}
	}
	
	func exposableFields() -> Dictionary<String, Any>? {
		return [
			name: textfieldElement.text ?? ""
		]
	}
	
	func styleDisabled() {
		self.textfieldElement.styleDisabledState()
	}
		
	func setupTimer(interval: CGFloat = 0.07) {
		timer.invalidate()
		timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(step), userInfo: nil, repeats: true)
		RunLoop.main.add(timer, forMode: .common)
	}

	@objc
	func increaseFlickerSize() {
		triggerHapticFeedback(style: .light)
		guard let sizeAnchor = flickerSizeAnchor else {
			return
		}

		sizeAnchor.constant = sizeAnchor.constant + 10
		flickerStackView.subviews.forEach { (subview) in
			subview.layoutIfNeeded()
			subview.sizeToFit()
		}
	}
	
	@objc
	func decreaseFlickerSize() {
		triggerHapticFeedback(style: .light)
		guard let sizeAnchor = flickerSizeAnchor else {
			return
		}

		sizeAnchor.constant = sizeAnchor.constant - 10
		flickerStackView.subviews.forEach { (subview) in
			subview.layoutIfNeeded()
			subview.sizeToFit()
		}
	}
	
	@objc
	func increaseFlickerSpeed() {
		triggerHapticFeedback(style: .light)
		let currentInterval = timer.timeInterval
		setupTimer(interval: currentInterval - 0.01)
	}
	
	@objc
	func decreaseFlickerSpeed() {
		triggerHapticFeedback(style: .light)
		let currentInterval = timer.timeInterval
		setupTimer(interval: currentInterval + 0.01)
	}

	override func viewDidDisappear(_ animated: Bool) {
		timer.invalidate()
	}
	
	@objc
	func rotateFlicker() {
		triggerHapticFeedback(style: .light)
		if flickerAlignment == .horizontal {
			flickerAlignment = .vertical
		} else {
			flickerAlignment = .horizontal
		}
		
		setupFlickerView()
	}
	
	private func setupFlickerView() {
		timer.invalidate()
		view.subviews.forEach({ $0.removeFromSuperview() })
		flickerContainer = []
		
		let smallerButton = UIButton()
		let minusGlassImage = UIImage(named: "minus_glass", in: .images, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
		smallerButton.setImage(minusGlassImage, for: .normal)
		smallerButton.tintColor = XS2A.shared.styleProvider.submitButtonStyle.textColor
		smallerButton.layer.cornerRadius = XS2A.shared.styleProvider.buttonBorderRadius
		smallerButton.backgroundColor = XS2A.shared.styleProvider.submitButtonStyle.backgroundColor
		smallerButton.addTarget(self, action: #selector(decreaseFlickerSize), for: .touchUpInside)
        smallerButton.isAccessibilityElement = true
        smallerButton.accessibilityLabel = getStringForKey(key: "FlickerLine.minus_glass")
		
		let biggerButton = UIButton()
		let plusGlassImage = UIImage(named: "plus_glass", in: .images, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
		biggerButton.setImage(plusGlassImage, for: .normal)
		biggerButton.tintColor = XS2A.shared.styleProvider.submitButtonStyle.textColor
		biggerButton.layer.cornerRadius = XS2A.shared.styleProvider.buttonBorderRadius
		biggerButton.backgroundColor = XS2A.shared.styleProvider.submitButtonStyle.backgroundColor
		biggerButton.addTarget(self, action: #selector(increaseFlickerSize), for: .touchUpInside)
        biggerButton.isAccessibilityElement = true
        biggerButton.accessibilityLabel = getStringForKey(key: "FlickerLine.plus_glass")
		
		let fasterButton = UIButton()
		let plusGaugeImage = UIImage(named: "gauge_plus", in: .images, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
		fasterButton.setImage(plusGaugeImage, for: .normal)
		fasterButton.tintColor = XS2A.shared.styleProvider.submitButtonStyle.textColor
		fasterButton.layer.cornerRadius = XS2A.shared.styleProvider.buttonBorderRadius
		fasterButton.backgroundColor = XS2A.shared.styleProvider.submitButtonStyle.backgroundColor
		fasterButton.addTarget(self, action: #selector(increaseFlickerSpeed), for: .touchUpInside)
        fasterButton.isAccessibilityElement = true
        fasterButton.accessibilityLabel = getStringForKey(key: "FlickerLine.gauge_plus")
		
		let slowerButton = UIButton()
		let minusGaugeImage = UIImage(named: "gauge_minus", in: .images, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
		slowerButton.setImage(minusGaugeImage, for: .normal)
		slowerButton.tintColor = XS2A.shared.styleProvider.submitButtonStyle.textColor
		slowerButton.layer.cornerRadius = XS2A.shared.styleProvider.buttonBorderRadius
		slowerButton.backgroundColor = XS2A.shared.styleProvider.submitButtonStyle.backgroundColor
		slowerButton.addTarget(self, action: #selector(decreaseFlickerSpeed), for: .touchUpInside)
        slowerButton.isAccessibilityElement = true
        slowerButton.accessibilityLabel = getStringForKey(key: "FlickerLine.gauge_minus")
		
		let rotateButton = UIButton()
		
		let rotateImage = UIImage(named: "rotate_clockwise", in: .images, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
		
		rotateButton.setImage(rotateImage, for: .normal)
		rotateButton.tintColor = XS2A.shared.styleProvider.submitButtonStyle.textColor
		rotateButton.layer.cornerRadius = XS2A.shared.styleProvider.buttonBorderRadius
		rotateButton.backgroundColor = XS2A.shared.styleProvider.submitButtonStyle.backgroundColor
		rotateButton.addTarget(self, action: #selector(rotateFlicker), for: .touchUpInside)
        rotateButton.isAccessibilityElement = true
        rotateButton.accessibilityLabel = getStringForKey(key: "FlickerLine.rotate_clockwise")
		
		let buttonStackView = UIStackView(arrangedSubviews: [biggerButton, smallerButton, slowerButton, fasterButton, rotateButton])
		buttonStackView.addCustomSpacing(10, after: biggerButton)
		buttonStackView.addCustomSpacing(10, after: smallerButton)
		buttonStackView.addCustomSpacing(10, after: slowerButton)
		buttonStackView.addCustomSpacing(10, after: fasterButton)
		buttonStackView.axis = .horizontal
		buttonStackView.distribution = .fillEqually
		
		let flickerMainContainer = UIView()
		let flickerContainer1 = FlickerContainer(withTriangle: true, alignment: flickerAlignment)
		let flickerContainer2 = FlickerContainer(withTriangle: false, alignment: flickerAlignment)
		let flickerContainer3 = FlickerContainer(withTriangle: false, alignment: flickerAlignment)
		let flickerContainer4 = FlickerContainer(withTriangle: false, alignment: flickerAlignment)
		let flickerContainer5 = FlickerContainer(withTriangle: true, alignment: flickerAlignment)
		
		let spacing1 = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
		let spacing2 = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))

		
		flickerStackView = UIStackView(arrangedSubviews: [
			spacing1,
			flickerContainer1,
			flickerContainer2,
			flickerContainer3,
			flickerContainer4,
			flickerContainer5,
			spacing2
		])
		
		flickerMainContainer.backgroundColor = .black
		flickerContainer1.backgroundColor = .white
		flickerContainer2.backgroundColor = .white
		flickerContainer3.backgroundColor = .white
		flickerContainer4.backgroundColor = .white
		flickerContainer5.backgroundColor = .white
		
		flickerContainer.append(flickerContainer1)
		flickerContainer.append(flickerContainer2)
		flickerContainer.append(flickerContainer3)
		flickerContainer.append(flickerContainer4)
		flickerContainer.append(flickerContainer5)

		switch flickerAlignment {
		case .horizontal:
			flickerStackView.axis = .horizontal
			flickerStackView.distribution = .equalSpacing
			flickerStackView.alignment = .center
			flickerStackView.translatesAutoresizingMaskIntoConstraints = false

			let flickerViewContainer = UIView()
			flickerViewContainer.addSubview(flickerStackView)
			
			flickerStackView.backgroundColor = .black
			
            let stackView = UIStackView(arrangedSubviews: [buttonStackView, flickerViewContainer, labelElement, subTextContainer])
			stackView.addCustomSpacing(5, after: labelElement)
			stackView.addCustomSpacing(10, after: buttonStackView)
			stackView.addCustomSpacing(10, after: flickerViewContainer)
			stackView.axis = .vertical
			stackView.distribution = .fill
			stackView.alignment = .fill

			view.addSubview(stackView)
			
			stackView.translatesAutoresizingMaskIntoConstraints = false
			
			flickerSizeAnchor = flickerStackView.widthAnchor.constraint(equalTo: self.view.widthAnchor)
			flickerSizeAnchor?.isActive = true

			NSLayoutConstraint.activate([
				stackView.topAnchor.constraint(equalTo: self.view.topAnchor),
				stackView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
				stackView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
				view.heightAnchor.constraint(equalTo: stackView.heightAnchor),
				flickerViewContainer.heightAnchor.constraint(equalToConstant: 100),
				flickerStackView.heightAnchor.constraint(equalToConstant: 100),
				spacing1.widthAnchor.constraint(equalTo: flickerStackView.widthAnchor, multiplier: 0.001),
				spacing2.widthAnchor.constraint(equalTo: flickerStackView.widthAnchor, multiplier: 0.001),
				flickerContainer1.heightAnchor.constraint(equalTo: flickerStackView.heightAnchor, multiplier: 0.9),
				flickerContainer1.widthAnchor.constraint(equalTo: flickerStackView.widthAnchor, multiplier: 0.15),
				flickerContainer2.heightAnchor.constraint(equalTo: flickerStackView.heightAnchor, multiplier: 0.9),
				flickerContainer2.widthAnchor.constraint(equalTo: flickerStackView.widthAnchor, multiplier: 0.15),
				flickerContainer3.heightAnchor.constraint(equalTo: flickerStackView.heightAnchor, multiplier: 0.9),
				flickerContainer3.widthAnchor.constraint(equalTo: flickerStackView.widthAnchor, multiplier: 0.15),
				flickerContainer4.heightAnchor.constraint(equalTo: flickerStackView.heightAnchor, multiplier: 0.9),
				flickerContainer4.widthAnchor.constraint(equalTo: flickerStackView.widthAnchor, multiplier: 0.15),
				flickerContainer5.heightAnchor.constraint(equalTo: flickerStackView.heightAnchor, multiplier: 0.9),
				flickerContainer5.widthAnchor.constraint(equalTo: flickerStackView.widthAnchor, multiplier: 0.15),
			])
		case .vertical:
			flickerStackView.axis = .vertical
			flickerStackView.distribution = .equalSpacing
			flickerStackView.alignment = .center
			flickerStackView.translatesAutoresizingMaskIntoConstraints = false

			let flickerViewContainer = UIView()
			flickerViewContainer.addSubview(flickerStackView)
			
			flickerStackView.backgroundColor = .black
			
            let stackView = UIStackView(arrangedSubviews: [buttonStackView, flickerViewContainer, labelElement, subTextContainer])
			stackView.addCustomSpacing(5, after: labelElement)
			stackView.addCustomSpacing(10, after: buttonStackView)
			stackView.addCustomSpacing(10, after: flickerViewContainer)
			stackView.axis = .vertical
			stackView.distribution = .fill
			stackView.alignment = .fill

			view.addSubview(stackView)
			
			stackView.translatesAutoresizingMaskIntoConstraints = false
			
			flickerSizeAnchor = flickerStackView.heightAnchor.constraint(equalToConstant: 500)
			flickerSizeAnchor?.isActive = true
			
			NSLayoutConstraint.activate([
				flickerStackView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
				stackView.topAnchor.constraint(equalTo: self.view.topAnchor),
				stackView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
				stackView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
				view.heightAnchor.constraint(equalTo: stackView.heightAnchor),
				flickerViewContainer.heightAnchor.constraint(equalToConstant: 500),
				spacing1.widthAnchor.constraint(equalTo: flickerStackView.widthAnchor, multiplier: 0.001),
				spacing2.widthAnchor.constraint(equalTo: flickerStackView.widthAnchor, multiplier: 0.001),
				flickerContainer1.heightAnchor.constraint(equalTo: flickerStackView.heightAnchor, multiplier: 0.15),
				flickerContainer1.widthAnchor.constraint(equalTo: flickerStackView.widthAnchor, multiplier: 0.9),
				flickerContainer2.heightAnchor.constraint(equalTo: flickerStackView.heightAnchor, multiplier: 0.15),
				flickerContainer2.widthAnchor.constraint(equalTo: flickerStackView.widthAnchor, multiplier: 0.9),
				flickerContainer3.heightAnchor.constraint(equalTo: flickerStackView.heightAnchor, multiplier: 0.15),
				flickerContainer3.widthAnchor.constraint(equalTo: flickerStackView.widthAnchor, multiplier: 0.9),
				flickerContainer4.heightAnchor.constraint(equalTo: flickerStackView.heightAnchor, multiplier: 0.15),
				flickerContainer4.widthAnchor.constraint(equalTo: flickerStackView.widthAnchor, multiplier: 0.9),
				flickerContainer5.heightAnchor.constraint(equalTo: flickerStackView.heightAnchor, multiplier: 0.15),
				flickerContainer5.widthAnchor.constraint(equalTo: flickerStackView.widthAnchor, multiplier: 0.9),
			])
		}
		
		setupTimer()

		UIScreen.main.brightness = 1
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupFlickerView()
        
        setupAccessibility()
	}
    
    private func setupAccessibility() {
        flickerStackView.isAccessibilityElement = false
        labelElement.isAccessibilityElement = false
        subTextContainer.isAccessibilityElement = false
        textfieldElement.isAccessibilityElement = true
        textfieldElement.accessibilityLabel = "\(labelElement.text ?? "")."
        
        if (invalid) {
            view.accessibilityHint = "\(getStringForKey(key: "Input.Error")): \(errorMessage ?? "")"
        } else if (isRequired) {
            view.accessibilityHint = getStringForKey(key: "Input.Required")
        } else {
            view.accessibilityHint = nil
        }
        
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
       if focused === textfieldElement {
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
