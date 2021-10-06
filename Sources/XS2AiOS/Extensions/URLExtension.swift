/// Extension for getting query parameters from a URL
/// From Stackoverflow Answer: https://stackoverflow.com/a/46603619
/// By User Hexfire https://stackoverflow.com/users/4634527/hexfire
import Foundation

extension URL {
	var queryDictionary: [String: String]? {
		guard let query = self.query else { return nil}

		var queryStrings = [String: String]()
		for pair in query.components(separatedBy: "&") {

			let key = pair.components(separatedBy: "=")[0]

			let value = pair
				.components(separatedBy:"=")[1]
				.replacingOccurrences(of: "+", with: " ")
				.removingPercentEncoding ?? ""

			queryStrings[key] = value
		}
		return queryStrings
	}
}
