import XCTest
@testable import XS2AiOS

final class FlickerLineSnapshotTests: SnapshotTestCase {

    func test_default() {
        assertSnapshots(named: "FlickerLine_default") {
            FlickerLine(
                name: "tan",
                code: [[1, 0, 1, 0, 1], [0, 1, 0, 1, 0]],
                label: "ChipTAN",
                invalid: false,
                index: 0,
                placeholder: "Enter TAN",
                isRequired: false,
                errorMessage: nil
            )
        }
    }
}
