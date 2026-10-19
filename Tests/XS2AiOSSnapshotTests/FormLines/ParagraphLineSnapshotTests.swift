import XCTest
@testable import XS2AiOS

final class ParagraphLineSnapshotTests: SnapshotTestCase {

    func test_none() {
        assertSnapshots(named: "ParagraphLine_none") {
            ParagraphLine(
                title: "Information",
                text: "Please log in using your online banking credentials.",
                severity: .none
            )
        }
    }

    func test_info() {
        assertSnapshots(named: "ParagraphLine_info") {
            ParagraphLine(
                title: "Note",
                text: "Your session will expire in 10 minutes.",
                severity: .info
            )
        }
    }

    func test_warning() {
        assertSnapshots(named: "ParagraphLine_warning") {
            ParagraphLine(
                title: "Warning",
                text: "Entering incorrect credentials multiple times may lock your account.",
                severity: .warning
            )
        }
    }

    func test_error() {
        assertSnapshots(named: "ParagraphLine_error") {
            ParagraphLine(
                title: "Error",
                text: "Your session has expired. Please start over.",
                severity: .error
            )
        }
    }
}
