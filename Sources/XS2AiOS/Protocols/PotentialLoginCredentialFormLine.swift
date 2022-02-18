/// Protocol all FormLines that can be a login credential conform to
protocol PotentialLoginCredentialFormLine {
	var isLoginCredential: Bool { get }
	var name: String { get }
	
	func setValue(value: String)
}
