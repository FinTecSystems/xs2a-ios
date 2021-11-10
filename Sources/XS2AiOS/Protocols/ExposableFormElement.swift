/// Protocol all FormLines that have user entered values to be extracted have to comply with
protocol ExposableFormElement {
	func exposableFields() -> Dictionary<String, Any>?
}
