import XCTest
@testable import XS2AiOS

// A 120×40 solid-colour PNG delivered as a data: URL —
// the format imageForBase64String() actually expects (URL string, not raw base64).
private let testImageURL = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAHgAAAAoCAIAAAC6iKlyAAAAZElEQVR4nO3QAQkAIADAMAOZ0mBms4XCHTzA2Zhr60Lj+cEngQbdCjToVqBBtwINuhVo0K1Ag24FGnQr0KBbgQbdCjToVqBBtwINuhVo0K1Ag24FGnQr0KBbgQbdCjToVqBBtzrrUaqHldFYswAAAABJRU5ErkJggg=="

final class ImageLineSnapshotTests: SnapshotTestCase {

    func test_default() {
        assertSnapshots(named: "ImageLine_default") {
            ImageLine(data: testImageURL, description: "Bank logo")
        }
    }
}
