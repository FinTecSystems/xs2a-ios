import XCTest
@testable import XS2AiOS

final class RestartLineSnapshotTests: SnapshotTestCase {

    func test_default() {
        assertSnapshots(named: "RestartLine_default") {
            RestartLine(label: "Restart")
        }
    }
}
