import Foundation
import SwiftyJSON
@_implementationOnly import XS2AiOSNetService

/// The different Types of Responses from the API
enum APIResponseType {
	/// Most common response, returning form elements
	case success([FormLine], containsError: Bool = false)
	/// Response type after the flow is completed
	case finish
	/// Response type after the flow is completed with XS2A.API and sync_mode = shared
	/// Carries a credential parameter
	case finishWithCredentials(String)
	/// Networking Errors
	case failure(Error)
}


/// Structs for decoding JSON from autocomplete responses
struct AutocompleteRootResult: Codable {
	let autocomplete: AutocompleteData
}

struct AutocompleteData: Codable {
	let data: [AutocompleteResult]
}

struct AutocompleteResult: Codable {
	let label: String
	let value: String
}

class APIService {
	/// The Wizard Session Key used for the instance of the session
	public let wizardSessionKey: String
	
	private let netServiceInstance: XS2ANetService
	
	var notificationDelegate: NetworkNotificationDelegate?
	
	var baseURL = "https://api.xs2a.com/jsonp"
	
	/**
	 - Parameters:
	  - wizardSessionKey: the Wizard Session Key used for the instance of the session
	*/
	init(wizardSessionKey: String, baseURL: String) {
		self.wizardSessionKey = wizardSessionKey
		self.baseURL = baseURL
		self.netServiceInstance = XS2ANetService()
	}
	
	internal func cancelTask() {
		netServiceInstance.cancelTask()
	}
	
	/// Function for handling the response from the post method
	private func responseHandler(result: JSON, completion: @escaping (APIResponseType) -> Void) {
		if result["callback"] == "finish" {
			/// Session is finished
			/// Check if callbackParams are provided (only the case for XS2A.API with sync_mode = shared)
			if result["callbackParams"].array?.isEmpty == false {
				let callbackParam = result["callbackParams"].arrayValue[0]
				completion(.finishWithCredentials(callbackParam.stringValue))
			} else {
				completion(.finish)
			}
		} else {
//			print(result)
			if result["callbackParams"].array?.isEmpty == false {
				let callbackParam = result["callbackParams"].arrayValue[0]
				if let callbackDic = callbackParam.dictionaryObject {
					if let provider = callbackDic["provider"] {
						XS2AiOS.shared.configuration.provider = String(describing: provider)
					}
				}
			}
			
			var payloadContainsAnError = false
			
			// If an error is part of the response, we notify the host app of it, including the recoverable parameter
			if let error = result["error"].string {
				payloadContainsAnError = true
				let isRecoverable = result["isErrorRecoverable"].boolValue

				switch error {
				case "login_failed":
					notificationDelegate?.notifyOfSessionError(error: .loginFailed(recoverable: isRecoverable))
				case "session_timeout":
					notificationDelegate?.notifyOfSessionError(error: .sessionTimeout(recoverable: isRecoverable))
				case "tan_failed":
					notificationDelegate?.notifyOfSessionError(error: .tanFailed(recoverable: isRecoverable))
				case "tech_error":
					notificationDelegate?.notifyOfSessionError(error: .techError(recoverable: isRecoverable))
				case "testmode_error":
					notificationDelegate?.notifyOfSessionError(error: .testmodeError(recoverable: isRecoverable))
				case "trans_not_possible":
					notificationDelegate?.notifyOfSessionError(error: .transNotPossible(recoverable: isRecoverable))
				case "validation_failed":
					notificationDelegate?.notifyOfSessionError(error: .validationFailed(recoverable: isRecoverable))
				default:
					notificationDelegate?.notifyOfSessionError(error: .other(errorCode: error, recoverable: isRecoverable))
				}
			}

			completion(.success(decodeJSON(json: result), containsError: payloadContainsAnError))
		}
	}
	
	
	
	/// Function for making the initial call to the XS2A backend
	func initCall(completion: @escaping (APIResponseType) -> Void) {
		let payload: [String:Any] = [
			"version": "ios_sdk_1.2.6",
			"client": "ios_sdk",
		]

		post(body: payload, completion: { result, error in
			if let error = error {
				completion(.failure(error))
				
				return
			}

			if let result = result {
				/// Check if server sent a language
				guard let languageFromServer = result["language"].string else {
					/// Server did not send a language, leave as is
					self.responseHandler(result: result, completion: completion)
					
					return
				}

				/// The preferred localization of the client device
				let deviceLocalization = String(Locale.preferredLanguages[0].prefix(2))

				/// Check if we support the device language
				if (["de", "en", "es", "fr", "it"].contains(deviceLocalization) && languageFromServer != deviceLocalization) {
					/// Language sent from server is not device language, but we know we support the device language, so lets change it
					self.notifyServerOfLanguageChange(newLocalization: deviceLocalization, completion: completion)
					
					return
				}

				self.responseHandler(result: result, completion: completion)
			}
		})
	}
	
	/// After the initCall, this function might be called to change the language of the session
	private func notifyServerOfLanguageChange(newLocalization: String, completion: @escaping (APIResponseType) -> Void) -> Void {
		let payload: [String:Any] = [
			"action": "change-language",
			"language": newLocalization
		]

		post(body: payload, completion: { result, error in
			if let error = error {
				completion(.failure(error))
				
				return
			}
			
			if let result = result {
				self.responseHandler(result: result, completion: completion)
			}
		})
	}

	/// Function for posting to the backend
	/// All networking requests pass through this function
	func postBody(payload: Dictionary<String, Any>, completion: @escaping (APIResponseType) -> Void) {
		post(body: payload, completion: { result, error in
			if let error = error {
				completion(.failure(error))
				
				return
			}
			
			if let result = result {
				self.responseHandler(result: result, completion: completion)
			}
		})
	}

	/// Function for getting autocomplete results for the bank search
	func autocomplete(countryId: String, bankCode: String, completion: @escaping ([AutocompleteResult]?, Error?) -> Void) {
		let requestPayload: [String:Any] = [
			"bank_code": bankCode,
			"country_id": countryId,
			"count": 5,
			"action": "complete-bankcodes"
		]

		post(body: requestPayload, completion: { result, error in
			if let result = result {
				do {
					let results = try JSONDecoder().decode(AutocompleteRootResult.self, from: result.rawData())
					completion(results.autocomplete.data, nil)
				} catch {
					completion(nil, error)
				}
			} else {
				completion(nil, error ?? XS2AError.networkError)
			}
		})
	}


	func post(body: Dictionary<String, Any>, completion: @escaping (JSON?, Error?) -> Void) {
		DispatchQueue.global(qos: .userInitiated).async {
			self.netServiceInstance.postCustom(body: body, endpoint: self.baseURL, sessionKey: self.wizardSessionKey) { result in
				DispatchQueue.main.async {
					switch result {
					case .success(let data):
						completion(JSON(data), nil)
					case .failure(let error):
						completion(nil, error)
					}
				}
			}
		}
	}
}
