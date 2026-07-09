import XCTest
@testable import XS2AiOS

final class SubmitLineSnapshotTests: SnapshotTestCase {

    func test_submit() {
        assertSnapshots(named: "SubmitLine_submit") {
            SubmitLine(label: "Continue", actionType: .submit)
        }
    }

    func test_back() {
        assertSnapshots(named: "SubmitLine_back") {
            SubmitLine(label: "Back", actionType: .back)
        }
    }

    func test_abort() {
        assertSnapshots(named: "SubmitLine_abort") {
            SubmitLine(label: "Cancel", actionType: .abort)
        }
    }
}
