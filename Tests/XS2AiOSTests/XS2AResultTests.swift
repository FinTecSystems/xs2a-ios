import XCTest
@testable import XS2AiOS

final class XS2AResultTests: XCTestCase {

    // MARK: - XS2ASuccess

    func testSuccess_finish() {
        let result = XS2ASuccess.finish
        guard case .finish = result else {
            XCTFail("Expected .finish"); return
        }
    }

    func testSuccess_finishWithCredentials() {
        let token = "shared-credential-token"
        let result = XS2ASuccess.finishWithCredentials(token)
        guard case .finishWithCredentials(let cred) = result else {
            XCTFail("Expected .finishWithCredentials"); return
        }
        XCTAssertEqual(cred, token)
    }

    // MARK: - XS2AError

    func testError_userAborted() {
        let error = XS2AError.userAborted
        guard case .userAborted = error else {
            XCTFail("Expected .userAborted"); return
        }
    }

    func testError_networkError() {
        let error = XS2AError.networkError
        guard case .networkError = error else {
            XCTFail("Expected .networkError"); return
        }
    }

    // MARK: - XS2ASessionError — recoverable flag

    func testSessionError_loginFailed_recoverableTrue() {
        let error = XS2ASessionError.loginFailed(recoverable: true)
        guard case .loginFailed(let recoverable) = error else {
            XCTFail("Expected .loginFailed"); return
        }
        XCTAssertTrue(recoverable)
    }

    func testSessionError_loginFailed_recoverableFalse() {
        let error = XS2ASessionError.loginFailed(recoverable: false)
        guard case .loginFailed(let recoverable) = error else {
            XCTFail("Expected .loginFailed"); return
        }
        XCTAssertFalse(recoverable)
    }

    func testSessionError_sessionTimeout_recoverable() {
        let error = XS2ASessionError.sessionTimeout(recoverable: true)
        guard case .sessionTimeout(let recoverable) = error else {
            XCTFail("Expected .sessionTimeout"); return
        }
        XCTAssertTrue(recoverable)
    }

    func testSessionError_tanFailed_notRecoverable() {
        let error = XS2ASessionError.tanFailed(recoverable: false)
        guard case .tanFailed(let recoverable) = error else {
            XCTFail("Expected .tanFailed"); return
        }
        XCTAssertFalse(recoverable)
    }

    func testSessionError_techError_recoverable() {
        let error = XS2ASessionError.techError(recoverable: true)
        guard case .techError(let recoverable) = error else {
            XCTFail("Expected .techError"); return
        }
        XCTAssertTrue(recoverable)
    }

    func testSessionError_testmodeError_notRecoverable() {
        let error = XS2ASessionError.testmodeError(recoverable: false)
        guard case .testmodeError(let recoverable) = error else {
            XCTFail("Expected .testmodeError"); return
        }
        XCTAssertFalse(recoverable)
    }

    func testSessionError_transNotPossible_recoverable() {
        let error = XS2ASessionError.transNotPossible(recoverable: true)
        guard case .transNotPossible(let recoverable) = error else {
            XCTFail("Expected .transNotPossible"); return
        }
        XCTAssertTrue(recoverable)
    }

    func testSessionError_validationFailed_notRecoverable() {
        let error = XS2ASessionError.validationFailed(recoverable: false)
        guard case .validationFailed(let recoverable) = error else {
            XCTFail("Expected .validationFailed"); return
        }
        XCTAssertFalse(recoverable)
    }

    func testSessionError_other_withCustomCode() {
        let error = XS2ASessionError.other(errorCode: "custom_bank_error", recoverable: true)
        guard case .other(let code, let recoverable) = error else {
            XCTFail("Expected .other"); return
        }
        XCTAssertEqual(code, "custom_bank_error")
        XCTAssertTrue(recoverable)
    }

    func testSessionError_other_notRecoverable() {
        let error = XS2ASessionError.other(errorCode: "fatal_error", recoverable: false)
        guard case .other(let code, let recoverable) = error else {
            XCTFail("Expected .other"); return
        }
        XCTAssertEqual(code, "fatal_error")
        XCTAssertFalse(recoverable)
    }

    // MARK: - XS2AResult generic container

    func testResult_success() {
        let result: XS2AResult<XS2ASuccess, XS2AError, XS2ASessionError> = .success(.finish)
        guard case .success(let value) = result, case .finish = value else {
            XCTFail("Expected .success(.finish)"); return
        }
    }

    func testResult_failure_userAborted() {
        let result: XS2AResult<XS2ASuccess, XS2AError, XS2ASessionError> = .failure(.userAborted)
        guard case .failure(let error) = result, case .userAborted = error else {
            XCTFail("Expected .failure(.userAborted)"); return
        }
    }

    func testResult_sessionError_loginFailed() {
        let result: XS2AResult<XS2ASuccess, XS2AError, XS2ASessionError> = .sessionError(.loginFailed(recoverable: true))
        guard case .sessionError(let sessionError) = result,
              case .loginFailed(let recoverable) = sessionError else {
            XCTFail("Expected .sessionError(.loginFailed)"); return
        }
        XCTAssertTrue(recoverable)
    }

    func testResult_success_withCredentials() {
        let result: XS2AResult<XS2ASuccess, XS2AError, XS2ASessionError> = .success(.finishWithCredentials("token-abc"))
        guard case .success(let value) = result,
              case .finishWithCredentials(let cred) = value else {
            XCTFail("Expected .success(.finishWithCredentials)"); return
        }
        XCTAssertEqual(cred, "token-abc")
    }
}
