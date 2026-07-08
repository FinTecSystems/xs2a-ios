import XCTest
@testable import XS2AiOS

final class RedirectLineSnapshotTests: SnapshotTestCase {

    func test_default() {
        assertSnapshots(named: "RedirectLine_default") {
            RedirectLine(label: "Continue in browser", url: "https://example.com")
        }
    }
}
