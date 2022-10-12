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
	case image
	case tabs
	case logo
}


/**
 Function for decoding JSON to Form Line Elements
 - Parameters:
   - json: The JSON from the backend response
   - indexOffset: Sometimes the function is called recursively, this lets us pass an offset so we can keep order
*/
func decodeJSON(json: JSON, indexOffset: Int? = 0) -> [FormLine] {
	/// Set current WizardStep
	if let wizardStep = json["callback"].string {
		XS2AiOS.shared.currentStep = WizardStep(rawValue: wizardStep)
	}
	
	if let wizardStepNormalized = json["step"].string {
		XS2AiOS.shared.currentStepNormalized = WizardStep(rawValue: wizardStepNormalized)
	}
	
	/// "form" is an array of multiple form lines to be rendered
	let form = json["form"]

	/// Array containing the form lines to be returned
	var formClasses: [FormLine] = []

	if let formArray = form.array {
		for (formElementIndex, formElement) in formArray.enumerated() {
			if let elementType = FormLineTypes(rawValue: formElement["type"].stringValue) {
				/**
				 Switch depending on form type.
				 */
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
							isLoginCredential: formElement["login_credential"].boolValue
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
							invalid: formElement["invalid"].boolValue
						)
					)
				case .description:
					formClasses.append(
						DescriptionLine(
							text: formElement["text"].stringValue
						)
					)
				case .submit:
					formClasses.append(
						SubmitLine(
							label: formElement["label"].stringValue,
							actionType: .submit
						)
					)

					if XS2AiOS.shared.configuration.enableBackButton && formElement["back"].string != nil {
						formClasses.append(
							SubmitLine(
								label: formElement["back"].stringValue,
								actionType: .back
							)
						)
					}
					XS2AiOS.shared.backButtonIsPresent = formElement["back"].string != nil
				case .restart:
					formClasses.append(
						RestartLine(
							label: formElement["label"].stringValue
						)
					)
				case .abort:
					formClasses.append(
						SubmitLine(
							label: formElement["label"].stringValue,
							actionType: .abort
						)
					)
				case .paragraph:
					formClasses.append(
						ParagraphLine(
							title: formElement["title"].stringValue,
							text: formElement["text"].stringValue,
							severity: Severity(rawValue: formElement["severity"].stringValue) ?? .none
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
							isLoginCredential: formElement["login_credential"].boolValue
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
							index: formElementIndex
						)
					)
				case .redirect:
					formClasses.append(
						RedirectLine(
							label: formElement["label"].stringValue,
							url: formElement["url"].stringValue
						)
					)
					
					if XS2AiOS.shared.configuration.enableBackButton && formElement["back"].string != nil {
						formClasses.append(
							SubmitLine(
								label: formElement["back"].stringValue,
								actionType: .back
							)
						)
					}
					XS2AiOS.shared.backButtonIsPresent = formElement["back"].string != nil
				case .hidden:
					formClasses.append(
						HiddenLine(
							name: formElement["name"].stringValue,
							value: formElement["value"].stringValue
						)
					)
				case .checkbox:
					formClasses.append(
						CheckboxLine(
							label: formElement["label"].stringValue,
							checked: formElement["checked"].boolValue,
							name: formElement["name"].stringValue,
							disabled: formElement["disabled"].boolValue,
							isLoginCredential: formElement["name"].stringValue == "privacy_policy"
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
							index: formElementIndex
						)
					)
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
							options: formattedRadioOptions
						)
					)
				case .autosubmit:
					formClasses.append(
						AutosubmitLine(
							interval: formElement["interval"].intValue
						)
					)
				case .image:
					formClasses.append(
						ImageLine(
							data: formElement["data"].stringValue
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
							tabs: tabsDic
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

	return formClasses
}
