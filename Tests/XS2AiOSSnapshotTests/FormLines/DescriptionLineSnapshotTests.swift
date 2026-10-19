import XCTest
@testable import XS2AiOS

final class DescriptionLineSnapshotTests: SnapshotTestCase {

    func test_default() {
        assertSnapshots(named: "DescriptionLine_default") {
            DescriptionLine(
                text: "Enter your IBAN to connect your bank account. Your data is transmitted securely."
            )
        }
    }
}
