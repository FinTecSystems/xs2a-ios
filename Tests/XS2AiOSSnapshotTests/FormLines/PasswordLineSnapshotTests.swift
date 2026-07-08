import XCTest
@testable import XS2AiOS

final class PasswordLineSnapshotTests: SnapshotTestCase {

    func test_default() {
        assertSnapshots(named: "PasswordLine_default") {
            PasswordLine(
                name: "password",
                label: "Password",
                disabled: false,
                placeholder: "Enter password",
                invalid: false,
                index: 0,
                isLoginCredential: true,
                isRequired: false,
                errorMessage: nil
            )
        }
    }

    func test_required() {
        assertSnapshots(named: "PasswordLine_required") {
            PasswordLine(
                name: "password",
                label: "Password",
                disabled: false,
                placeholder: "Enter password",
                invalid: false,
                index: 0,
                isLoginCredential: true,
                isRequired: true,
                errorMessage: nil
            )
        }
    }

    func test_invalid() {
        assertSnapshots(named: "PasswordLine_invalid") {
            PasswordLine(
                name: "password",
                label: "Password",
                disabled: false,
                placeholder: "Enter password",
                invalid: true,
                index: 0,
                isLoginCredential: true,
                isRequired: false,
                errorMessage: "Password is incorrect."
            )
        }
    }
}
