import XCTest
@testable import XS2AiOS

final class RadioLineSnapshotTests: SnapshotTestCase {

    func test_default() {
        assertSnapshots(named: "RadioLine_default") {
            RadioLine(
                label: "Choose your account type",
                checked: 0,
                name: "account_type",
                options: [
                    (label: "Checking Account", disabled: false),
                    (label: "Savings Account", disabled: false),
                    (label: "Business Account", disabled: true)
                ]
            )
        }
    }
}
