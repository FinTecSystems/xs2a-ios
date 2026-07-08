import XCTest
@testable import XS2AiOS

final class SelectLineSnapshotTests: SnapshotTestCase {

    func test_empty() {
        assertSnapshots(named: "SelectLine_empty") {
            SelectLine(
                options: ["DE": "Germany", "AT": "Austria", "CH": "Switzerland"],
                label: "Country",
                selected: "",
                name: "country",
                invalid: false,
                isRequired: false,
                errorMessage: nil
            )
        }
    }

    func test_withSelection() {
        assertSnapshots(named: "SelectLine_withSelection") {
            SelectLine(
                options: ["DE": "Germany", "AT": "Austria", "CH": "Switzerland"],
                label: "Country",
                selected: "DE",
                name: "country",
                invalid: false,
                isRequired: false,
                errorMessage: nil
            )
        }
    }

    func test_invalid() {
        assertSnapshots(named: "SelectLine_invalid") {
            SelectLine(
                options: ["DE": "Germany", "AT": "Austria"],
                label: "Country",
                selected: "",
                name: "country",
                invalid: true,
                isRequired: true,
                errorMessage: "Please select a country."
            )
        }
    }
}
