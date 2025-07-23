import UIKit

class SelectLine: UIViewController, FormLine, ExposableFormElement, UIPickerViewDelegate, UIPickerViewDataSource, ErrorableFormLine {
    var actionDelegate: ActionDelegate?
    
    private var options: [(id: String, label: Any)] = []
    var selectedElementId: String? = nil
    
    private let label: String
    private let isRequired: Bool
    internal let invalid: Bool
    internal let errorMessage: String?
    internal let name: String

    private let labelElement = UILabel.make(size: .large)
    private let pickerElement = UIPickerView()
    let textfieldElement = SelectTextfield()
    let subTextContainer: SubTextContainer
    let toolbar = UIToolbar()
    
    /**
     - Parameters:
       - options: The available options for this select line
       - label: The label for this select line
       - selected: The key of the (pre)selected option
       - name: The name for this select line
       - invalid: If this select is invalid
       - isRequired: If this field is required
       - errorMessage: If this field contains a validation error
    */
    init(options: Dictionary<String, Any>, label: String, selected: String, name: String, invalid: Bool, isRequired: Bool, errorMessage: String?) {
        /// Add default disabled row
        self.options.append((id: "disabled", label: Strings.choose))

        for (id, label) in options {
            self.options.append((id: id, label: label))
        }

        self.label = label
        self.selectedElementId = selected
        self.name = name
        self.invalid = invalid
        self.isRequired = isRequired
        self.errorMessage = errorMessage
        
        if !selected.isEmpty {
            self.textfieldElement.text = options[selected] as? String
        } else {
            self.textfieldElement.attributedPlaceholder = NSAttributedString(
                string: Strings.choose,
                attributes: [NSAttributedString.Key.foregroundColor: XS2A.shared.styleProvider.placeholderColor]
            )
        }
        
        labelElement.text = label
        
        if invalid {
            textfieldElement.styleTextfield(style: .error)
        }
        
        subTextContainer = SubTextContainer(contentView: textfieldElement)
        if (invalid) {
            subTextContainer.showMessage(errorMessage, isError: true)
        } else if (isRequired) {
            subTextContainer.showMessage(getStringForKey(key: "Input.Required"), isError: false, prefix: "*")
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textfieldElement.inputView = pickerElement
        pickerElement.delegate = self
        pickerElement.dataSource = self

        /// In case we get a preselected value from the server, set the corresponding text
        if let selectedIndex = self.options.firstIndex(where: { $0.id == selectedElementId }) {
            textfieldElement.text = self.options[selectedIndex].label as? String
            pickerElement.selectRow(selectedIndex, inComponent: 0, animated: false)
        }
        
        let stackView = UIStackView(arrangedSubviews: [labelElement, subTextContainer])
        stackView.addCustomSpacing(5, after: labelElement)
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: self.view.topAnchor),
            stackView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            stackView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            view.heightAnchor.constraint(equalTo: stackView.heightAnchor)
        ])
        
        setupAccessibility()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func exposableFields() -> Dictionary<String, Any>? {
        return [
            self.name: selectedElementId ?? ""
        ]
    }
    
    func styleDisabled() {
        self.textfieldElement.styleDisabledState()
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        if row == 0 {
            var attributes = [NSAttributedString.Key: AnyObject]()
            attributes[.foregroundColor] = UIColor.systemGray

            let attributedString = NSAttributedString(string: self.options[row].label as? String ?? Strings.choose, attributes: attributes)

            return attributedString
        }
        
        return NSAttributedString(string: self.options[row].label as! String)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return options.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return options[row].label as? String
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true // needed for Done button for VoiceOver users
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 0 {
            /// If the first row ("Choose ...") row was selected, roll to next row
            pickerView.selectRow(1, inComponent: 0, animated: true)

            return
        }

        textfieldElement.text = options[row].label as? String
        selectedElementId = options[row].id
        
        view.accessibilityValue = textfieldElement.text
        UIAccessibility.post(notification: .announcement, argument: textfieldElement.text)
        
        if !UIAccessibility.isVoiceOverRunning {
            textfieldElement.resignFirstResponder()
        }
    }
    
    private func setupAccessibility() {
        subTextContainer.isAccessibilityElement = false
        view.isAccessibilityElement = true
        view.accessibilityTraits = .adjustable
        view.accessibilityLabel = label
        
        if (invalid) {
            view.accessibilityHint = "\(getStringForKey(key: "Input.Error")): \(errorMessage ?? ""). \(getStringForKey(key: "SelectLine.Hint"))"
        } else if (isRequired) {
            view.accessibilityHint = "\(getStringForKey(key: "Input.Required")). \(getStringForKey(key: "SelectLine.Hint"))"
        } else {
            view.accessibilityHint = getStringForKey(key: "SelectLine.Hint")
        }
        
        view.accessibilityValue = textfieldElement.text ?? Strings.choose
        pickerElement.isAccessibilityElement = true
        pickerElement.accessibilityTraits = .adjustable
        pickerElement.accessibilityLabel = label
        pickerElement.accessibilityHint = getStringForKey(key: "SelectLine.PickerHint")

        toolbar.sizeToFit()
        let done = UIBarButtonItem(
            title: getStringForKey(key: "SelectLine.Done"),
            style: .done,
            target: self,
            action: #selector(donePicking)
        )
        let flexible: UIBarButtonItem
        if #available(iOS 14.0, *) {
            flexible = .flexibleSpace()
        } else {
            flexible = UIBarButtonItem(
                barButtonSystemItem: .flexibleSpace,
                target: nil,
                action: nil
            )
        }
        toolbar.setItems([flexible, done], animated: false)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(voiceOverToggled),
            name: UIAccessibility.voiceOverStatusDidChangeNotification,
            object: nil
        )
        voiceOverToggled()
    }
    
    @objc private func voiceOverToggled() {
        textfieldElement.inputAccessoryView = UIAccessibility.isVoiceOverRunning ? toolbar : nil
    }
    
    @objc private func donePicking() {
        view.accessibilityValue = textfieldElement.text
        textfieldElement.resignFirstResponder()
        UIAccessibility.post(
            notification: .layoutChanged,
            argument: textfieldElement
        )
    }

    override func accessibilityActivate() -> Bool {
        if textfieldElement.isFirstResponder {
            textfieldElement.resignFirstResponder()
            UIAccessibility.post(notification: .screenChanged, argument: view)
        } else {
            textfieldElement.becomeFirstResponder()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                UIAccessibility.post(
                    notification: .screenChanged,
                    argument: self.pickerElement
                )
            }
        }
        return true
    }
    
    override func accessibilityIncrement() {
        let next = min(pickerElement.selectedRow(inComponent:0)+1, options.count-1)
        pickerElement.selectRow(next, inComponent:0, animated:true)
        let label = options[next].label as? String ?? ""
        view.accessibilityValue = label
        UIAccessibility.post(notification: .announcement, argument: label)
    }

    override func accessibilityDecrement() {
        let prev = max(pickerElement.selectedRow(inComponent:0)-1, 0)
        pickerElement.selectRow(prev, inComponent:0, animated:true)
        let label = options[prev].label as? String ?? ""
        view.accessibilityValue = label
        UIAccessibility.post(notification: .announcement, argument: label)
    }
}
