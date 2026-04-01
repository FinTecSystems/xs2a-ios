//
//  XS2AiOSNetService.swift
//  XS2AiOSNetService
//
//  Created by Felix Fritz on 05.03.21.
//

import CommonCrypto
import Foundation
import Security

public enum XS2ANetError: Error {
	case networkError
}

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
	
	private static func getPw() throws -> String {
		/// Uses cryptographically secure random number generator according to Apple Docs:
		/// https://developer.apple.com/documentation/security/1399291-secrandomcopybytes
		var bytes = [UInt8](repeating: 0, count: 100)
		let status = SecRandomCopyBytes(kSecRandomDefault, 100, &bytes)
		if status == errSecSuccess {
			return Data(bytes).base64EncodedString()
		} else {
			throw XS2ANetError.networkError
		}
	}

	private static func encryptData(stringToEncrypt: String) throws -> String {
		guard let pw = try? getPw() else {
			throw XS2ANetError.networkError
		}

		let publicKeyDER = Data(base64Encoded: publicKey, options: [.ignoreUnknownCharacters])!
		let cipherKey = try rsaEncrypt(data: pw.data(using: .utf8)!, spkiDerKey: publicKeyDER)
		let crypted = try aesEncrypt(input: stringToEncrypt, passphrase: pw)

		let keyHex = cipherKey.map { String(format: "%02x", $0) }.joined()
		return "\(keyHex)::\(crypted)"
	}

	/// Encrypts `input` with AES-256-CBC using an OpenSSL-compatible EVP_BytesToKey key derivation
	/// (MD5-based, 3 rounds), producing the "Salted__" prefixed, base64-encoded output that the
	/// server expects.
	private static func aesEncrypt(input: String, passphrase: String) throws -> String {
		var salt = [UInt8](repeating: 0, count: 8)
		guard SecRandomCopyBytes(kSecRandomDefault, 8, &salt) == errSecSuccess else {
			throw XS2ANetError.networkError
		}

		let (key, iv) = evpBytesToKey(passphrase: passphrase, salt: salt)
		let inputBytes = Array(input.utf8)
		let bufferSize = inputBytes.count + kCCBlockSizeAES128
		var buffer = [UInt8](repeating: 0, count: bufferSize)
		var numBytesEncrypted = 0

		let status = CCCrypt(
			CCOperation(kCCEncrypt),
			CCAlgorithm(kCCAlgorithmAES),
			CCOptions(kCCOptionPKCS7Padding),
			key, kCCKeySizeAES256,
			iv,
			inputBytes, inputBytes.count,
			&buffer, bufferSize,
			&numBytesEncrypted
		)

		guard status == kCCSuccess else {
			throw XS2ANetError.networkError
		}

		let result = Array("Salted__".utf8) + salt + Array(buffer[0..<numBytesEncrypted])
		return Data(result).base64EncodedString()
	}

	/// OpenSSL EVP_BytesToKey equivalent: derives a 32-byte key and 16-byte IV from
	/// a passphrase and salt using three rounds of MD5.
	private static func evpBytesToKey(passphrase: String, salt: [UInt8]) -> (key: [UInt8], iv: [UInt8]) {
		let pass = Array(passphrase.utf8)
		var dx = [UInt8]()
		var di = [UInt8]()

		for _ in 0..<3 {
			var input = di + pass + salt
			var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
			CC_MD5(&input, CC_LONG(input.count), &digest)
			di = digest
			dx += di
		}

		return (key: Array(dx[0..<32]), iv: Array(dx[32..<48]))
	}

	/// Encrypts `data` with RSA-PKCS1 using the given DER-encoded SubjectPublicKeyInfo key.
	private static func rsaEncrypt(data: Data, spkiDerKey: Data) throws -> Data {
		guard let rsaKeyData = extractRSAPublicKey(from: spkiDerKey) else {
			throw XS2ANetError.networkError
		}

		let attributes: [CFString: Any] = [
			kSecAttrKeyType: kSecAttrKeyTypeRSA,
			kSecAttrKeyClass: kSecAttrKeyClassPublic,
			kSecAttrKeySizeInBits: 2048
		]

		var error: Unmanaged<CFError>?
		guard let publicKey = SecKeyCreateWithData(rsaKeyData as CFData, attributes as CFDictionary, &error) else {
			throw XS2ANetError.networkError
		}

		guard let encrypted = SecKeyCreateEncryptedData(publicKey, .rsaEncryptionPKCS1, data as CFData, &error) else {
			throw XS2ANetError.networkError
		}

		return encrypted as Data
	}

	/// Strips the SubjectPublicKeyInfo (SPKI) DER wrapper, returning the inner RSAPublicKey
	/// in PKCS#1 format required by `SecKeyCreateWithData`.
	private static func extractRSAPublicKey(from spki: Data) -> Data? {
		var bytes = [UInt8](spki)
		var idx = 0

		/// Reads a DER length field, advances `idx` past it, and returns the decoded length.
		func readLength() -> Int? {
			guard idx < bytes.count else { return nil }
			let first = bytes[idx]
			if first & 0x80 == 0 {
				idx += 1
				return Int(first)
			}
			let numLenBytes = Int(first & 0x7f)
			guard idx + numLenBytes < bytes.count else { return nil }
			var len = 0
			for i in 1...numLenBytes {
				len = (len << 8) | Int(bytes[idx + i])
			}
			idx += 1 + numLenBytes
			return len
		}

		// Outer SEQUENCE
		guard bytes[idx] == 0x30 else { return nil }
		idx += 1
		guard readLength() != nil else { return nil }

		// AlgorithmIdentifier SEQUENCE — skip tag + length + content
		guard idx < bytes.count, bytes[idx] == 0x30 else { return nil }
		idx += 1
		guard let algIdLen = readLength() else { return nil }
		idx += algIdLen

		// BIT STRING — skip tag + length, then the 0x00 "unused bits" padding byte
		guard idx < bytes.count, bytes[idx] == 0x03 else { return nil }
		idx += 1
		guard readLength() != nil else { return nil }
		idx += 1

		return Data(bytes[idx...])
	}
	
	public func cancelTask() {
		self.task.cancel()
	}

	public func post(body: Dictionary<String, Any>, sessionKey: String, completion: @escaping ((Result<Data, Error>) -> Void)) {
		let endpoint = "https://api.xs2a.com/jsonp"

		do {
			guard let jsonEncoded = try? JSONSerialization.data(withJSONObject: body) else {
				throw XS2ANetError.networkError
			}
			
			let jsonEncodedString = String(data: jsonEncoded, encoding: String.Encoding.utf8)
			
			guard let encryptedBodyData = try? XS2ANetService.encryptData(stringToEncrypt: jsonEncodedString!) else {
				throw XS2ANetError.networkError
			}

			let payload = [
				"data": encryptedBodyData,
				"key": sessionKey
			]
			
			guard let payloadJSON = try? JSONSerialization.data(withJSONObject: payload) else {
				throw XS2ANetError.networkError
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
	
	public func postCustom(body: Dictionary<String, Any>, endpoint: String = "http://192.168.178.44:8080/jsonp", sessionKey: String, completion: @escaping ((Result<Data, Error>) -> Void)) {
		do {
			guard let jsonEncoded = try? JSONSerialization.data(withJSONObject: body) else {
				throw XS2ANetError.networkError
			}
			
			let jsonEncodedString = String(data: jsonEncoded, encoding: String.Encoding.utf8)
			
			guard let encryptedBodyData = try? XS2ANetService.encryptData(stringToEncrypt: jsonEncodedString!) else {
				throw XS2ANetError.networkError
			}

			let payload = [
				"data": encryptedBodyData,
				"key": sessionKey
			]
			
			guard let payloadJSON = try? JSONSerialization.data(withJSONObject: payload) else {
				throw XS2ANetError.networkError
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
}

