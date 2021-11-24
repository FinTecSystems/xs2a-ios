import SwiftyJSON

enum FormLineTypes: String {
	case text
	case select
	case description
	case submit
	case restart
	case abort
	case paragraph
	case checkbox
	case autosubmit
	case password
	case captcha
	case redirect
	case radio
	case flicker
	case hidden
	case multi
	case image
	case tabs
	case logo
}


/**
 Function for decoding JSON to Form Line Elements
 - Parameters:
   - json: The JSON from the backend response
   - indexOffset: Sometimes the function is called recursively, this lets us pass an offset so we can keep order
   - multiFormName: When called recursively, this parameter passes the multi form name for every Form Line
   - multiFormValue: When called recursively, this parameter passes the multi form value for every Form Line
*/
func decodeJSON(json: JSON, indexOffset: Int? = 0, multiFormName: String? = nil, multiFormValue: String? = nil) -> [FormLine] {
	
	/// "form" is an array of multiple form lines to be rendered
	let form = json["form"]
	print(form)
	/// Array containing the form lines to be returned
	var formClasses: [FormLine] = []

	if let formArray = form.array {
		for formElement in formArray {
			if let elementType = FormLineTypes(rawValue: formElement["type"].stringValue) {
				/**
				The index to be used for the element to be decoded. Normally it is simply the index the element has in the formClasses array,
				but in case of MultiForms, this function is called recursively and might get passed an offset.
				*/
				let formElementIndex = formClasses.count + indexOffset!

				switch elementType {
				case .text:
					formClasses.append(
						TextLine(
							name: formElement["name"].stringValue,
							label: formElement["label"].stringValue,
							disabled: formElement["disabled"].boolValue,
							invalid: formElement["invalid"].boolValue,
							autocompleteAction: formElement["autocomplete_action"].stringValue,
							value: formElement["value"].stringValue,
							placeholder: formElement["placeholder"].stringValue,
							index: formElementIndex,
							isLoginCredential: formElement["login_credential"].boolValue,
							multiFormName: multiFormName,
							multiFormValue: multiFormValue
						)
					)
				case .select:
					/// Sometimes options get send as array, sometimes as object ("0": "some value")
					
					/// The dictionary to use for initializing the SelectLine
					var optionsDic: Dictionary<String, Any> = [:]

					if let selectOptionsArray = formElement["options"].array {
						/// options is an array, rewrite it to dictionary
						for (index, option) in selectOptionsArray.enumerated() {
							optionsDic[String(index)] = option.stringValue
						}
					} else if let selectOptionsDic = formElement["options"].dictionaryObject {
						/// Is a dictionary already, good to go
						optionsDic = selectOptionsDic
					}

					formClasses.append(
						SelectLine(
							options: optionsDic, label: formElement["label"].stringValue,
							selected: formElement["selected"].stringValue,
							name: formElement["name"].stringValue,
							invalid: formElement["invalid"].boolValue,
							multiFormName: multiFormName,
							multiFormValue: multiFormValue
						)
					)
				case .description:
					formClasses.append(
						DescriptionLine(
							text: formElement["text"].stringValue,
							multiFormName: multiFormName,
							multiFormValue: multiFormValue
						)
					)
				case .submit:
					formClasses.append(
						SubmitLine(
							label: formElement["label"].stringValue,
							actionType: .submit,
							multiFormName: multiFormName,
							multiFormValue: multiFormValue
						)
					)
					
					if formElement["back"].string != nil {
						formClasses.append(
							SubmitLine(
								label: formElement["back"].stringValue,
								actionType: .back,
								multiFormName: multiFormName,
								multiFormValue: multiFormValue
							)
						)
					}
				case .restart:
					formClasses.append(
						RestartLine(
							label: formElement["label"].stringValue,
							multiFormName: multiFormName,
							multiFormValue: multiFormValue
						)
					)
				case .abort:
					formClasses.append(
						SubmitLine(
							label: formElement["label"].stringValue,
							actionType: .abort,
							multiFormName: multiFormName,
							multiFormValue: multiFormValue
						)
					)
				case .paragraph:
					formClasses.append(
						ParagraphLine(
							title: formElement["title"].stringValue,
							text: formElement["text"].stringValue,
							severity: Severity(rawValue: formElement["severity"].stringValue) ?? .none,
							multiFormName: multiFormName,
							multiFormValue: multiFormValue
						)
					)
				case .password:
					formClasses.append(
						PasswordLine(
							name: formElement["name"].stringValue,
							label: formElement["label"].stringValue,
							disabled: formElement["disabled"].boolValue,
							placeholder: formElement["placeholder"].stringValue,
							invalid: formElement["invalid"].boolValue,
							index: formElementIndex,
							isLoginCredential: formElement["login_credential"].boolValue,
							multiFormName: multiFormName,
							multiFormValue: multiFormValue
						)
					)
				case .captcha:
					formClasses.append(
						CaptchaLine(
							name: formElement["name"].stringValue,
							label: formElement["label"].stringValue,
							imageData: formElement["data"].stringValue,
							placeholder: formElement["placeholder"].stringValue,
							invalid: formElement["invalid"].boolValue,
							index: formElementIndex,
							multiFormName: multiFormName,
							multiFormValue: multiFormValue
						)
					)
				case .redirect:
					formClasses.append(
						RedirectLine(
							label: formElement["label"].stringValue,
							url: formElement["url"].stringValue,
							multiFormName: multiFormName,
							multiFormValue: multiFormValue
						)
					)
					
					if formElement["back"].string != nil {
						formClasses.append(
							SubmitLine(
								label: formElement["back"].stringValue,
								actionType: .back,
								multiFormName: multiFormName,
								multiFormValue: multiFormValue
							)
						)
					}
				case .hidden:
					formClasses.append(
						HiddenLine(
							name: formElement["name"].stringValue,
							value: formElement["value"].stringValue,
							multiFormName: multiFormName,
							multiFormValue: multiFormValue
						)
					)
				case .checkbox:
					formClasses.append(
						CheckboxLine(
							label: formElement["label"].stringValue,
							checked: formElement["checked"].boolValue,
							name: formElement["name"].stringValue,
							disabled: formElement["disabled"].boolValue,
							isLoginCredential: formElement["name"].stringValue == "privacy_policy",
							multiFormName: multiFormName,
							multiFormValue: multiFormValue
						)
					)
				case .flicker:
					/**
					 The "code" array comes in like this:
					 `[[1, 0, 1, 0, 1],[1, 0, 1, 0, 1], ...]`
					 We simply cast everything appropriately.
					*/
					let intArray = formElement["code"].arrayValue.compactMap({ $0.arrayValue.compactMap({ $0.intValue }) })
					
					formClasses.append(
						FlickerLine(
							name: formElement["name"].stringValue,
							code: intArray,
							label: formElement["label"].stringValue,
							invalid: formElement["invalid"].boolValue,
							index: formElementIndex,
							multiFormName: multiFormName,
							multiFormValue: multiFormValue
						)
					)
				case .multi:
					formClasses.append(
						MultiFormController(
							name: formElement["name"].stringValue,
							selectedMultiFormValue: formElement["selected"].stringValue,
							forms: formElement["forms"].arrayValue
						)
					)
					
					/**
					In order to assign the correct indices for the subform elements, we carry over the current index
					*/
					var indexOffset = formElementIndex + 1

					for multiForm in formElement["forms"].arrayValue.enumerated() {
						/// For every sub-form we recursively call this function again and attach the form lines in order
						let decodedFormClasses = decodeJSON(
							json: multiForm.element,
							indexOffset: indexOffset,
							multiFormName: formElement["name"].stringValue,
							multiFormValue: multiForm.element["value"].stringValue
						)
						
						formClasses.append(contentsOf: decodedFormClasses)
						/// Recalculate the offset based on how many elements have been added in this iteration
						indexOffset += decodedFormClasses.count
					}
				case .radio:
					var formattedRadioOptions: [(label: String, disabled: Bool)] = []
					for option in formElement["options"].arrayValue.enumerated() {
						if option.element.stringValue != "" {
							formattedRadioOptions.append(
								(
									label: option.element.stringValue,
									disabled: false
								)
							)
						} else if option.element.dictionaryValue.count > 0 {
							formattedRadioOptions.append(
								(
									label: option.element.dictionaryValue["label"]!.stringValue,
									disabled: option.element.dictionaryValue["disabled"]!.boolValue
								)
							)
						}
					}
					
					formClasses.append(
						RadioLine(
							label: formElement["label"].stringValue,
							checked: formElement["checked"].intValue,
							name: formElement["name"].stringValue,
							options: formattedRadioOptions,
							multiFormName: multiFormName,
							multiFormValue: multiFormValue
						)
					)
				case .autosubmit:
					formClasses.append(
						AutosubmitLine(
							interval: formElement["interval"].intValue,
							multiFormName: multiFormName,
							multiFormValue: multiFormValue
						)
					)
				case .image:
					formClasses.append(
						ImageLine(
							data: formElement["data"].stringValue,
							multiFormName: multiFormName,
							multiFormValue: multiFormValue
						)
					)
				case .tabs:
					var tabsDic: Dictionary<String, String> = [:]
					if let selectOptionsDic = formElement["tabs"].dictionaryObject {
						for (key, value) in selectOptionsDic {
							tabsDic[key] = value as? String
						}
					}
					
					formClasses.append(
						TabLine(
							selected: formElement["selected"].stringValue,
							tabs: tabsDic,
							multiFormName: multiFormName,
							multiFormValue: multiFormValue
						)
					)
				case .logo:
					formClasses.append(
						LogoLine()
					)
				}
			} else {
				print("unkown \(formElement["type"].stringValue)")
			}
		}
	}
	
	
	
	/**
	 If form contains a FormLine of type LoginCredentialFormLine that is also used as such,
	 append a Checkbox that asks for storage, just before the submit button.
	 */
	if (formClasses.contains(where: { $0 is LoginCredentialFormLine && ($0 as? LoginCredentialFormLine)?.isLoginCredential == true })) {
		let submitIndex = formClasses.firstIndex(where: { $0 is SubmitLine })
		
		formClasses.insert(
			CheckboxLine(
				label: "Ich will speichern.",
				checked: false,
				name: "store_credentials",
				disabled: false,
				isLoginCredential: false,
				multiFormName: nil,
				multiFormValue: nil
			),
			at: submitIndex ?? formClasses.count
		)
	}
	
	return formClasses
}
