import XCTest
import SnapshotTesting
@testable import XS2AiOS

class SnapshotTestCase: XCTestCase {

    override func setUp() {
        super.setUp()
        isRecording = ProcessInfo.processInfo.environment["IS_RECORDING_SNAPSHOTS"] == "YES"
    }

    /// Runs the factory closure once per theme, configures XS2A.shared for each,
    /// and asserts a pixel-perfect snapshot. The snapshot name encodes both the
    /// test name and the theme: e.g. "TextLine_default_defaultLight".
    func assertSnapshots(
        named testName: String,
        file: StaticString = #file,
        line: UInt = #line,
        factory: () -> UIViewController
    ) {
        for theme in snapshotThemes {
            XS2A.configure(
                withConfig: XS2A.Configuration(wizardSessionKey: "snapshot-test"),
                withStyle: theme.style
            )

            let vc = factory()

            // Embed in a window so UIKit hierarchy is complete
            let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 2000))
            window.rootViewController = vc
            window.makeKeyAndVisible()

            vc.loadViewIfNeeded()
            vc.view.setNeedsLayout()
            vc.view.layoutIfNeeded()

            // Compute the intrinsic height at 390pt width
            let fittingHeight = vc.view.systemLayoutSizeFitting(
                CGSize(width: 390, height: UIView.layoutFittingCompressedSize.height),
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel
            ).height

            let size = CGSize(width: 390, height: max(fittingHeight, 1))
            let config = ViewImageConfig(
                safeArea: .zero,
                size: size,
                traits: UITraitCollection()
            )

            assertSnapshot(
                matching: vc,
                as: .image(on: config),
                named: "\(testName)_\(theme.name)",
                file: file,
                line: line
            )
        }
    }
}
