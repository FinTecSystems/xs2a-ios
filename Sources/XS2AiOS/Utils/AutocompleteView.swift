import UIKit

class AutocompleteView: UIViewController, UITableViewDelegate, UITableViewDataSource {
	var notificationDelegate: NotificationDelegate?
	private var countryId: String
	private var results: [AutocompleteResult] = []
	
	private let label = UILabel.make(size: .large)
	private let infoLabel = UILabel()
	private let searchField = Textfield()
	private let nextButton: UIButton
	private let resultTable = UITableView()
	
	func reloadTable(with results: [AutocompleteResult]) {
		self.results = results
		self.resultTable.reloadSections([0], with: .fade)
		self.resultTable.tableFooterView = UIView()
	}
	
	func setElementVisibility() {
		guard let valueToSearch = self.searchField.text else {
			return
		}
		
		let startsAsIban = stringStartsAsIban(stringToTest: valueToSearch)
		let containsValidIban = stringContainsValidIban(stringToTest: valueToSearch)
		let isTooLong = valueToSearch.count > 36
		
		if (startsAsIban) {
			if (containsValidIban) {
				if (isTooLong) {
					infoLabel.isHidden = false
					infoLabel.text = Strings.AutocompleteView.ibanTooLongNotice
					nextButton.isHidden = true
				} else {
					infoLabel.isHidden = true
					nextButton.isHidden = false
				}
			} else {
				infoLabel.isHidden = false
				infoLabel.text = Strings.AutocompleteView.ibanTypingNotice
				nextButton.isHidden = true
			}
		} else {
			resultTable.isHidden = false
		}
	}
	
	func getAutocompleteResults() {
		guard let valueToSearch = self.searchField.text else {
			return
		}
		
		setElementVisibility()
		
		let startsAsIban = stringStartsAsIban(stringToTest: valueToSearch)

		if (!startsAsIban) {
			XS2AiOS.shared.apiService.autocomplete(countryId: self.countryId, bankCode: valueToSearch) { (result, error) in
				guard let result = result else {
					return
				}

				self.reloadTable(with: result)
			}
		}
	}

	
	@objc func textFieldDidChange(_ textField: UITextField) {
		if let searchText = searchField.text {
			let startsAsIban = stringStartsAsIban(stringToTest: searchText)
			
			if (startsAsIban) {
				setElementVisibility()
			} else {
				infoLabel.isHidden = true
				getAutocompleteResults()
			}
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 44
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return results.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = resultTable.dequeueReusableCell(withIdentifier: "resultCell") as! ResultCell
		
		let attributedString = NSMutableAttributedString(string: results[indexPath.row].label)
		
		if let searchFieldText = searchField.text {
			let filterRange = (results[indexPath.row].label as NSString).range(of: searchFieldText, options: .caseInsensitive)
			attributedString.setAttributes([.font: UIFont.boldSystemFont(ofSize: 14)], range: filterRange)
			cell.resultTextLabel.attributedText = attributedString
		}

		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		searchField.text = results[indexPath.row].value
		self.view.endEditing(true)
		notificationDelegate?.notifyWithSelectedBank(selectedBank: results[indexPath.row].value)
		dismiss(animated: true, completion: nil)
	}
	
	init(countryId: String, label: String, prefilledText: String?, maxlength: Int?) {
		self.countryId = countryId
		self.label.text = label
		self.infoLabel.text = Strings.AutocompleteView.notice
		self.infoLabel.numberOfLines = 3
		self.searchField.maxlength = maxlength
		self.searchField.autocorrectionType = .no
		self.nextButton = UIButton.make(buttonType: .submit)
		self.nextButton.setTitle(Strings.next, for: .normal)

		
		let font = XS2AiOS.shared.styleProvider.font.getFont(ofSize: 14, ofWeight: nil)
		let italicFont = UIFont(descriptor: font.fontDescriptor.withSymbolicTraits(.traitItalic)!, size: 14)
		
		self.infoLabel.font = italicFont

		super.init(nibName: nil, bundle: nil)

		/// Attach nextButtonTapped function to the radio button
		nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
		
		if prefilledText?.isEmpty == false {
			self.searchField.text = prefilledText
			self.infoLabel.isHidden = true
		}
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	@objc func nextButtonTapped(sender: UIButton) {
		self.view.endEditing(true)
		notificationDelegate?.notifyWithSelectedBank(selectedBank: searchField.text ?? "")
		dismiss(animated: true, completion: nil)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		if #available(iOS 13.0, *) {
			overrideUserInterfaceStyle = .light
		}

		view.backgroundColor = XS2AiOS.shared.styleProvider.backgroundColor
		searchField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
		resultTable.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

		nextButton.isHidden = true
		
		if let searchFieldText = searchField.text {
			if searchFieldText.count > 0 {
				/// This gets called when the view opens with an already filled in value
				getAutocompleteResults()
			}
		} else {
			resultTable.isHidden = true
		}

		let nib = UINib(nibName: "ResultCell", bundle: .module)
		resultTable.register(nib, forCellReuseIdentifier: "resultCell")
		resultTable.delegate = self
		resultTable.dataSource = self
		
		/// Hides empty cells on load
		resultTable.tableFooterView = UIView()
		
		searchField.becomeFirstResponder()

		let stackView = UIStackView(arrangedSubviews: [label, searchField, infoLabel, nextButton, resultTable])
		stackView.setCustomSpacing(10, after: searchField)
		stackView.axis = .vertical
		stackView.distribution = .fill

		view.addSubview(stackView)
		
		stackView.translatesAutoresizingMaskIntoConstraints = false
		
		var topPadding: CGFloat = 0
		if modalPresentationStyle == .pageSheet {
			topPadding = 20
		}

		NSLayoutConstraint.activate([
			stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: topPadding),
			stackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
			stackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
			resultTable.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height),
		])
	}
}
