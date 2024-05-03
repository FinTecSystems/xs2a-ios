//
//  XS2AiOSNetService.swift
//  XS2AiOSNetService
//
//  Created by Felix Fritz on 05.03.21.
//

import Foundation

public enum XS2ANetError: Error {
	case encryptionError
	case jsonSerializationError
	case generatePasswordError
	case networkError
}

/*
 * RSA Public Key.
 */
private let publicKey = """
	MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA4sDTEJhYgx1UlP7nzQte
	P/nGyNyPfge4t83kBXEJTkxAYRBJ7Q3tICQscZ1FFIaFrnCaYPtcqSiXADAlrGvr
	rISJaK6eKQn6hOhpSwaDAJ99Rj5wIB6FSC23UW0m0C1cieBPMpagUYOdtqnLtJOr
	ZYDRIXesvbsbgo02IYmVikaRY6dL/fjcipBY2aCvX5DKeuesx3weMp6/SRq2eCWK
	3L70FXRfKBNirVqI4cSGrOX6d6ieKGDRpde4s8pRUyg5YttuDAAnHm8wBMSPfRC6
	cJC49vGN+lAW7U/ecqhHgPdfiCqW2IEn/SJzHiFcD+YDS8eqBtnYAZ2C82GMn4Nk
	sQIDAQAB
"""


public class XS2ANetService {
	private var task = URLSessionDataTask()
	
	public init() {}
	
	/**
	 Generates a random password to be encrypted using RSA.
	 Uses cryptographically secure random number generator according to Apple Docs:
	 See: https://developer.apple.com/documentation/security/1399291-secrandomcopybytes
	 */
	private static func generatePassword() throws -> String {
		var bytes = [UInt8](repeating: 0, count: 100)
		let status = SecRandomCopyBytes(kSecRandomDefault, 100, &bytes)
		if status == errSecSuccess {
			return Data(bytes).base64EncodedString()
		} else {
			throw XS2ANetError.generatePasswordError
		}
	}

	/**
	 Encrypts a string using RSA and AES.
	 */
	private static func encryptData(stringToEncrypt: String) throws -> String {
		do {
			guard let password = try? generatePassword() else {
				throw XS2ANetError.generatePasswordError
			}
			
			let publicKeyDER = Data(base64Encoded: publicKey, options: [.ignoreUnknownCharacters])
			let cipherKey = try CC.RSA.encrypt(password.data(using: .utf8)!, derKey: publicKeyDER!, tag: Data(), padding: .pkcs1, digest: .none)
			
			let crypted = try AES256.encrypt(input: stringToEncrypt, passphrase: password)

			let keyHex = cipherKey.map { String(format: "%02x", $0) }.joined()

			return "\(keyHex)::\(crypted)"
		} catch {
			print(error)
			throw error
		}
	}
	
	public func cancelTask() {
		self.task.cancel()
	}

	public func post(body: Dictionary<String, Any>, sessionKey: String, completion: @escaping ((Result<Data, Error>) -> Void)) {
		let endpoint = "https://api.xs2a.com/jsonp"

		do {
			guard let jsonEncoded = try? JSONSerialization.data(withJSONObject: body) else {
				throw XS2ANetError.jsonSerializationError
			}
			
			let jsonEncodedString = String(data: jsonEncoded, encoding: String.Encoding.utf8)
			
			guard let encryptedBodyData = try? XS2ANetService.encryptData(stringToEncrypt: jsonEncodedString!) else {
				throw XS2ANetError.encryptionError
			}

			let payload = [
				"data": encryptedBodyData,
				"key": sessionKey
			]
			
			guard let payloadJSON = try? JSONSerialization.data(withJSONObject: payload) else {
				throw XS2ANetError.jsonSerializationError
			}
			
			var request = URLRequest(url: URL(string: endpoint)!)
			request.httpMethod = "POST"
			request.setValue("application/json", forHTTPHeaderField: "Content-Type")
			request.httpBody = payloadJSON
			request.timeoutInterval = 180

			task = URLSession.shared.dataTask(with: request) { (data, response, error) in
				guard let response = response as? HTTPURLResponse,
					  (200 ..< 300) ~= response.statusCode,
					  let data = data else {
						  if let urlError = error as? URLError {
							  if urlError.code == .cancelled {
								  return
							  }
						  }
						  completion(.failure(error ?? XS2ANetError.networkError))

						  return
				}

				completion(.success(data))
			}
			
			task.resume()
		} catch {
			completion(.failure(error))
		}
	}
	
	public func postCustom(body: Dictionary<String, Any>, endpoint: String = "https://api.xs2a.com/jsonp", sessionKey: String, completion: @escaping ((Result<Data, Error>) -> Void)) {
		do {
			guard let jsonEncoded = try? JSONSerialization.data(withJSONObject: body) else {
				throw XS2ANetError.jsonSerializationError
			}
			
			let jsonEncodedString = String(data: jsonEncoded, encoding: String.Encoding.utf8)
			
			guard let encryptedBodyData = try? XS2ANetService.encryptData(stringToEncrypt: jsonEncodedString!) else {
				throw XS2ANetError.encryptionError
			}

			let payload = [
				"data": encryptedBodyData,
				"key": sessionKey
			]
			
			guard let payloadJSON = try? JSONSerialization.data(withJSONObject: payload) else {
				throw XS2ANetError.jsonSerializationError
			}
			
			var request = URLRequest(url: URL(string: endpoint)!)
			request.httpMethod = "POST"
			request.setValue("application/json", forHTTPHeaderField: "Content-Type")
			request.httpBody = payloadJSON
			request.timeoutInterval = 180

			task = URLSession.shared.dataTask(with: request) { (data, response, error) in
				guard let response = response as? HTTPURLResponse,
					  (200 ..< 300) ~= response.statusCode,
					  let data = data else {
						  if let urlError = error as? URLError {
							  print(urlError)

							  if urlError.code == .cancelled {
								  return
							  }
						  }
					completion(.failure(error ?? XS2ANetError.networkError))
					
					return
				}

				completion(.success(data))
			}

			task.resume()
		} catch {
			completion(.failure(error))
		}
	}
}

