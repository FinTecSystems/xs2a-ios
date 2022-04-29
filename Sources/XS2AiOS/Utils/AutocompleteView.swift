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
	
	@objc func getAutocompleteResults() {
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

				/**
				 Debounce the API call.
				 */
				NSObject.cancelPreviousPerformRequests(
					withTarget: self,
					selector: #selector(getAutocompleteResults),
					object: nil
				)
				perform(#selector(getAutocompleteResults), with: nil, afterDelay: TimeInterval(0.4))
			}
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 54
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return results.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = resultTable.dequeueReusableCell(withIdentifier: "resultCell") as! ResultCell

		let attributedStringLine1 = NSMutableAttributedString(string: "\(results[indexPath.row].object.name)")
		
		if (results[indexPath.row].object.city.count > 0) {
			attributedStringLine1.append(NSMutableAttributedString(string: " (\(results[indexPath.row].object.city))"))
		}
		
		let attributedStringLine2 = NSMutableAttributedString(string: "")
		
		if (results[indexPath.row].object.bank_code.count > 0) {
			attributedStringLine2.append(
				NSMutableAttributedString(string: "\(results[indexPath.row].object.bank_code) (\(results[indexPath.row].object.bic))")
			)
		} else {
			attributedStringLine2.append(
				NSMutableAttributedString(string: "(\(results[indexPath.row].object.bic))")
			)
		}

		
		let line1Text = attributedStringLine1.string
		let line2Text = attributedStringLine2.string

		if let searchFieldText = searchField.text {
			var searchRangeLine1 = NSRange(location: 0, length: line1Text.count)
			var foundRangeLine1 = NSRange()
			
			var searchRangeLine2 = NSRange(location: 0, length: line2Text.count)
			var foundRangeLine2 = NSRange()

			while searchRangeLine1.location < line1Text.count {
				searchRangeLine1.length = line1Text.count - searchRangeLine1.location
				foundRangeLine1 = (line1Text as NSString).range(of: searchFieldText, options: .caseInsensitive, range: searchRangeLine1)
				if foundRangeLine1.location != NSNotFound {
					searchRangeLine1.location = foundRangeLine1.location + foundRangeLine1.length
					attributedStringLine1.setAttributes([.font: UIFont.boldSystemFont(ofSize: 15)], range: foundRangeLine1)
				}
				else {
					break
				}
			}
			
			while searchRangeLine2.location < line2Text.count {
				searchRangeLine2.length = line2Text.count - searchRangeLine2.location
				foundRangeLine2 = (line2Text as NSString).range(of: searchFieldText, options: .caseInsensitive, range: searchRangeLine2)
				if foundRangeLine2.location != NSNotFound {
					searchRangeLine2.location = foundRangeLine2.location + foundRangeLine2.length
					attributedStringLine2.setAttributes([.font: UIFont.boldSystemFont(ofSize: 12)], range: foundRangeLine2)
				}
				else {
					break
				}
			}
			
			cell.resultLabelLine1.attributedText = attributedStringLine1
			cell.resultLabelLine2.attributedText = attributedStringLine2
		}

		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		searchField.text = results[indexPath.row].value
		self.view.endEditing(true)
		notificationDelegate?.notifyWithSelectedBank(selectedBank: results[indexPath.row].value)
		dismiss(animated: true, completion: nil)
	}
	
	init(countryId: String, label: String, prefilledText: String?) {
		self.countryId = countryId
		self.label.text = label
	        self.infoLabel.textColor = XS2AiOS.shared.styleProvider.textColor
		self.infoLabel.text = Strings.AutocompleteView.notice
		self.infoLabel.numberOfLines = 3
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
	        resultTable.backgroundColor = .clear
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

		let nib = UINib(nibName: "ResultCell", bundle: .current)
		resultTable.register(nib, forCellReuseIdentifier: "resultCell")
		resultTable.delegate = self
		resultTable.dataSource = self
		
		/// Hides empty cells on load
		resultTable.tableFooterView = UIView()
		
		searchField.becomeFirstResponder()

		let stackView = UIStackView(arrangedSubviews: [label, searchField, infoLabel, nextButton, resultTable])
		stackView.addCustomSpacing(10, after: searchField)
		stackView.axis = .vertical
		stackView.distribution = .fill

		view.addSubview(stackView)
		
		stackView.translatesAutoresizingMaskIntoConstraints = false
		
		var topPadding: CGFloat = 0
		if modalPresentationStyle == .pageSheet {
			topPadding = 20
		}

		if #available(iOS 11.0, *) {
			NSLayoutConstraint.activate([
				stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: topPadding),
				stackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
				stackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
				resultTable.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height),
			])
		} else {
			NSLayoutConstraint.activate([
				stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: topPadding),
				stackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
				stackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
				resultTable.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height),
			])
		}
	}
}
