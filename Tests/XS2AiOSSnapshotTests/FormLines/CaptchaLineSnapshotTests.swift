import XCTest
@testable import XS2AiOS

// A 100×30 light-grey PNG encoded as base64 — used as a deterministic test image.
private let testCaptchaBase64 = "iVBORw0KGgoAAAANSUhEUgAAAGQAAAAeCAYAAADaW7vzAAAALklEQVR42u3BMQEAAADCoPVP7WsIoAAAAAAAAAAAAAAAAAAAAAAAAAAAeAMBxAAB4QgHdwAAAABJRU5ErkJggg=="

final class CaptchaLineSnapshotTests: SnapshotTestCase {

    func test_default() {
        assertSnapshots(named: "CaptchaLine_default") {
            CaptchaLine(
                name: "captcha",
                label: "Enter the characters shown",
                imageData: testCaptchaBase64,
                placeholder: "Enter captcha",
                invalid: false,
                index: 0,
                isRequired: false,
                errorMessage: nil
            )
        }
    }

    func test_invalid() {
        assertSnapshots(named: "CaptchaLine_invalid") {
            CaptchaLine(
                name: "captcha",
                label: "Enter the characters shown",
                imageData: testCaptchaBase64,
                placeholder: "Enter captcha",
                invalid: true,
                index: 0,
                isRequired: false,
                errorMessage: "The captcha you entered was incorrect."
            )
        }
    }
}
