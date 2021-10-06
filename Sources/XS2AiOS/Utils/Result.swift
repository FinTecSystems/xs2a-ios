public enum XS2ASuccess {
	case finish
	case finishWithCredentials(String)
}

public enum XS2AError: Error {
	case userAborted
	case networkError
}

public enum Result<XS2ASuccess, XS2AError> {
	case success(XS2ASuccess)
	case failure(XS2AError)
}
