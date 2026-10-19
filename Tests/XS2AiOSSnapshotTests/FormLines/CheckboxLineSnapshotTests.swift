import XCTest
@testable import XS2AiOS

final class CheckboxLineSnapshotTests: SnapshotTestCase {

    func test_unchecked() {
        assertSnapshots(named: "CheckboxLine_unchecked") {
            CheckboxLine(
                label: "I accept the terms and conditions",
                checked: false,
                name: "terms",
                disabled: false,
                isLoginCredential: false,
                invalid: false,
                isRequired: false,
                errorMessage: nil
            )
        }
    }

    func test_checked() {
        assertSnapshots(named: "CheckboxLine_checked") {
            CheckboxLine(
                label: "I accept the terms and conditions",
                checked: true,
                name: "terms",
                disabled: false,
                isLoginCredential: false,
                invalid: false,
                isRequired: false,
                errorMessage: nil
            )
        }
    }

    func test_invalid() {
        assertSnapshots(named: "CheckboxLine_invalid") {
            CheckboxLine(
                label: "I accept the terms and conditions",
                checked: false,
                name: "terms",
                disabled: false,
                isLoginCredential: false,
                invalid: true,
                isRequired: true,
                errorMessage: "You must accept the terms."
            )
        }
    }
}
