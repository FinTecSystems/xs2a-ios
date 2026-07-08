import XCTest
@testable import XS2AiOS

// Same small grey PNG used as a deterministic test image.
private let testImageBase64 = "iVBORw0KGgoAAAANSUhEUgAAAGQAAAAeCAYAAADaW7vzAAAALklEQVR42u3BMQEAAADCoPVP7WsIoAAAAAAAAAAAAAAAAAAAAAAAAAAAeAMBxAAB4QgHdwAAAABJRU5ErkJggg=="

final class ImageLineSnapshotTests: SnapshotTestCase {

    func test_default() {
        assertSnapshots(named: "ImageLine_default") {
            ImageLine(data: testImageBase64, description: "Bank logo")
        }
    }
}
