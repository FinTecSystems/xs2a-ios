import XCTest
@testable import XS2AiOS

final class TextLineSnapshotTests: SnapshotTestCase {

    func test_default() {
        assertSnapshots(named: "TextLine_default") {
            TextLine(
                name: "account",
                label: "Account Number",
                disabled: false,
                invalid: false,
                autocompleteAction: nil,
                value: "",
                placeholder: "Enter account number",
                index: 0,
                isLoginCredential: false,
                isRequired: false,
                errorMessage: nil
            )
        }
    }

    func test_required() {
        assertSnapshots(named: "TextLine_required") {
            TextLine(
                name: "account",
                label: "Account Number",
                disabled: false,
                invalid: false,
                autocompleteAction: nil,
                value: "",
                placeholder: "Enter account number",
                index: 0,
                isLoginCredential: false,
                isRequired: true,
                errorMessage: nil
            )
        }
    }

    func test_invalid() {
        assertSnapshots(named: "TextLine_invalid") {
            TextLine(
                name: "account",
                label: "Account Number",
                disabled: false,
                invalid: true,
                autocompleteAction: nil,
                value: "bad-value",
                placeholder: "Enter account number",
                index: 0,
                isLoginCredential: false,
                isRequired: false,
                errorMessage: "This field contains an error."
            )
        }
    }

    func test_disabled() {
        assertSnapshots(named: "TextLine_disabled") {
            TextLine(
                name: "account",
                label: "Account Number",
                disabled: true,
                invalid: false,
                autocompleteAction: nil,
                value: "pre-filled",
                placeholder: "Enter account number",
                index: 0,
                isLoginCredential: false,
                isRequired: false,
                errorMessage: nil
            )
        }
    }
}
