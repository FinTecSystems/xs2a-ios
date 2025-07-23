/// Protocol all FormLines that may contain a validation error.
protocol ErrorableFormLine {
    var invalid: Bool { get }
    var errorMessage: String? { get }
}
