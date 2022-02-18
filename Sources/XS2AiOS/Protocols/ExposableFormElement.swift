/// Protocol all FormLines that have user entered values to be extracted have to comply with
protocol ExposableFormElement {
	var name: String { get }
	func exposableFields() -> Dictionary<String, Any>?
	func styleDisabled()
}
