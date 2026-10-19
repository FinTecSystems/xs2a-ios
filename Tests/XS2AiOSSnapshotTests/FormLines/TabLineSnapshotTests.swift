import XCTest
@testable import XS2AiOS

final class TabLineSnapshotTests: SnapshotTestCase {

    func test_default() {
        assertSnapshots(named: "TabLine_default") {
            TabLine(
                selected: "iban",
                tabs: ["iban": "IBAN", "account": "Account Number"]
            )
        }
    }
}
