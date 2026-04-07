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

	// MARK: - Public API

	public func cancelTask() {
		task.cancel()
	}

	public func post(body: [String: Any], sessionKey: String, completion: @escaping (Result<Data, Error>) -> Void) {
		send(body: body, endpoint: "https://api.xs2a.com/jsonp", sessionKey: sessionKey, completion: completion)
	}

	public func postCustom(body: [String: Any], endpoint: String, sessionKey: String, completion: @escaping (Result<Data, Error>) -> Void) {
		send(body: body, endpoint: endpoint, sessionKey: sessionKey, completion: completion)
	}

	@available(*, deprecated, renamed: "post(body:sessionKey:completion:)")
	public func postCustom(body: [String: Any], sessionKey: String, completion: @escaping (Result<Data, Error>) -> Void) {
		post(body: body, sessionKey: sessionKey, completion: completion)
	}

	// MARK: - Private Networking

	private func send(body: [String: Any], endpoint: String, sessionKey: String, completion: @escaping (Result<Data, Error>) -> Void) {
		do {
			let request = try buildEncryptedRequest(body: body, endpoint: endpoint, sessionKey: sessionKey)
			task = URLSession.shared.dataTask(with: request) { data, response, error in
				guard let httpResponse = response as? HTTPURLResponse,
					  (200..<300).contains(httpResponse.statusCode),
					  let data = data else {
					if let urlError = error as? URLError, urlError.code == .cancelled {
						return
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

	private func buildEncryptedRequest(body: [String: Any], endpoint: String, sessionKey: String) throws -> URLRequest {
		let jsonEncoded = try JSONSerialization.data(withJSONObject: body)

		guard let jsonString = String(data: jsonEncoded, encoding: .utf8) else {
			throw XS2ANetError.networkError
		}

		let encryptedBody = try XS2ANetService.encryptData(stringToEncrypt: jsonString)
		let payloadJSON = try JSONSerialization.data(withJSONObject: ["data": encryptedBody, "key": sessionKey])

		guard let url = URL(string: endpoint) else {
			throw XS2ANetError.networkError
		}

		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		request.httpBody = payloadJSON
		request.timeoutInterval = 180
		return request
	}

	// MARK: - Private Crypto

	private static func encryptData(stringToEncrypt: String) throws -> String {
		let pw = try generatePassphrase()

		guard let publicKeyDER = Data(base64Encoded: publicKey, options: [.ignoreUnknownCharacters]),
			  let pwData = pw.data(using: .utf8) else {
			throw XS2ANetError.networkError
		}

		let cipherKey = try rsaEncrypt(data: pwData, spkiDerKey: publicKeyDER)
		let crypted = try aesEncrypt(input: stringToEncrypt, passphrase: pw)

		let keyHex = cipherKey.map { String(format: "%02x", $0) }.joined()
		return "\(keyHex)::\(crypted)"
	}

	/// Generates a cryptographically random 100-byte passphrase encoded as Base64.
	/// Uses SecRandomCopyBytes per Apple Docs:
	/// https://developer.apple.com/documentation/security/1399291-secrandomcopybytes
	private static func generatePassphrase() throws -> String {
		var bytes = [UInt8](repeating: 0, count: 100)
		guard SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes) == errSecSuccess else {
			throw XS2ANetError.networkError
		}
		return Data(bytes).base64EncodedString()
	}

	/// Encrypts `input` with AES-256-CBC using an OpenSSL-compatible EVP_BytesToKey key derivation
	/// (MD5-based, 3 rounds), producing the "Salted__" prefixed, base64-encoded output that the
	/// server expects.
	private static func aesEncrypt(input: String, passphrase: String) throws -> String {
		var salt = [UInt8](repeating: 0, count: 8)
		guard SecRandomCopyBytes(kSecRandomDefault, salt.count, &salt) == errSecSuccess else {
			throw XS2ANetError.networkError
		}

		let (key, iv) = evpBytesToKey(passphrase: passphrase, salt: salt)
		let inputBytes = Array(input.utf8)
		let bufferSize = inputBytes.count + kCCBlockSizeAES128
		var buffer = [UInt8](repeating: 0, count: bufferSize)
		var numBytesEncrypted = 0

		let status: CCCryptorStatus = key.withUnsafeBytes { keyBytes in
			iv.withUnsafeBytes { ivBytes in
				inputBytes.withUnsafeBytes { inputBytesRaw in
					buffer.withUnsafeMutableBytes { bufferRaw in
						CCCrypt(
							CCOperation(kCCEncrypt),
							CCAlgorithm(kCCAlgorithmAES),
							CCOptions(kCCOptionPKCS7Padding),
							keyBytes.baseAddress, kCCKeySizeAES256,
							ivBytes.baseAddress,
							inputBytesRaw.baseAddress, inputBytes.count,
							bufferRaw.baseAddress, bufferSize,
							&numBytesEncrypted
						)
					}
				}
			}
		}

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
			input.withUnsafeBytes { inputBuffer in
				digest.withUnsafeMutableBytes { digestBuffer in
					guard let inputPtr = inputBuffer.baseAddress,
						  let digestPtr = digestBuffer.bindMemory(to: UInt8.self).baseAddress else {
						return
					}
					CC_MD5(inputPtr, CC_LONG(input.count), digestPtr)
				}
			}
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
			kSecAttrKeyClass: kSecAttrKeyClassPublic
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
		guard idx < bytes.count, bytes[idx] == 0x30 else { return nil }
		idx += 1
		guard readLength() != nil else { return nil }

		// AlgorithmIdentifier SEQUENCE — skip tag + length + content
		guard idx < bytes.count, bytes[idx] == 0x30 else { return nil }
		idx += 1
		guard let algIdLen = readLength() else { return nil }
		guard idx + algIdLen <= bytes.count else { return nil }
		idx += algIdLen

		// BIT STRING — skip tag + length, then the 0x00 "unused bits" padding byte
		guard idx < bytes.count, bytes[idx] == 0x03 else { return nil }
		idx += 1
		guard let bitStringLen = readLength() else { return nil }
		guard bitStringLen > 0, idx + bitStringLen <= bytes.count else { return nil }
		idx += 1 // skip unused-bits indicator byte
		guard idx <= bytes.count else { return nil }

		return Data(bytes[idx...])
	}
}
