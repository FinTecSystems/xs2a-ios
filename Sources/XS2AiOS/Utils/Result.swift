public enum XS2ASuccess {
	/**
	 The session has finished.
	 */
	case finish
	/**
	 The session has finished and returned shared credentials.
	 */
	case finishWithCredentials(String)
}

public enum XS2AError: Error {
	/**
	 Used when the user presses the abort button or in case of popover presentation,
	 drags down the screen and aborts via the shown dialog.
	 */
	case userAborted
	/**
	 Used for any kind of networking error.
	 Not recoverable, an error screen needs to be shown.
	 */
	case networkError
}


/**
 Used for errors occuring during the session,
 can be `recoverable` or not. If it is recoverable,
 the user can simply continue, if not, the user will be shown
 an error description and an abort button.
 */
public enum XS2ASessionError: Error {
	/**
	 Login to bank failed (e.g. invalid login credentials)
	 */
	case loginFailed(recoverable: Bool)
	/**
	 The customer's session has timed out.
	 */
	case sessionTimeout(recoverable: Bool)
	/**
	 User entered invalid TAN.
	 */
	case tanFailed(recoverable: Bool)
	/**
	 An unknown or unspecified error occurred.
	 */
	case techError(recoverable: Bool)
	/**
	 An error occurred using testmode settings.
	 */
	case testmodeError(recoverable: Bool)
	/**
	 A transaction is not possible for various reasons.
	 */
	case transNotPossible(recoverable: Bool)
	/**
	 Validation error (e.g. entered letters instead of numbers).
	 */
	case validationFailed(recoverable: Bool)
	/**
	 A different error occurred.
	 */
	case other(errorCode: String, recoverable: Bool)
}

public enum Result<XS2ASuccess, XS2AError, XS2ASessionError> {
	/**
	 The session has finished successfully.
	 */
	case success(XS2ASuccess)
	/**
	 The session has been aborted or a network error has occurred.
	 */
	case failure(XS2AError)
	/**
	 Session errors occur during a session.
	 Implementation of the different cases below is optional.
	 No action needs to be taken for them, in fact we recommend
	 to let the user handle the completion of the session until one of the above `.success` or `.failure` cases is called.
	 You can however use below cases for measuring purposes.
	 NOTE: Should you decide to do navigation to different screens based on below cases, you should only do so
	 in case of the `recoverable` parameter being `false`, otherwise the user can still finish the session.
	 */
	case sessionError(XS2ASessionError)
}
