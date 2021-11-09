import Foundation
import SwiftyJSON
import XS2AiOSNetService

/// The different Types of Responses from the API
enum APIResponseType {
	/// Most common response, returning form elements
	case success([FormLine])
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
	
	/**
	 - Parameters:
	  - wizardSessionKey: the Wizard Session Key used for the instance of the session
	*/
	init(wizardSessionKey: String) {
		self.wizardSessionKey = wizardSessionKey
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
			completion(.success(decodeJSON(json: result)))
		}
	}
	
	
	
	/// Function for making the initial call to the XS2A backend
	func initCall(completion: @escaping (APIResponseType) -> Void) {
		let payload: [String:Any] = [
			"version": "ios_sdk_1.0.4",
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
			NetService.post(body: body, sessionKey: self.wizardSessionKey) { result in
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
