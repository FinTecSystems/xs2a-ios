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
                withConfig: XS2A.Configuration(wizardSessionKey: "snapshot-test", baseURL: "http://localhost:0"),
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

    /// Variant of `assertSnapshots` for view controllers that need a fixed snapshot
    /// size and/or post-load state injection.
    ///
    /// - Parameters:
    ///   - size: Fixed size used for every snapshot. Use this when a view controller
    ///     contains fixed-height constraints (e.g. a full-screen table view) that would
    ///     make the auto-computed height unwieldy.
    ///   - postLoad: Called after `loadViewIfNeeded()` and `layoutIfNeeded()` but before
    ///     the snapshot is taken. Use this to inject state without going through the
    ///     network (e.g. calling `reloadTable(with:)` on a search controller).
    func assertSnapshots(
        named testName: String,
        size: CGSize,
        postLoad: ((UIViewController) -> Void)? = nil,
        file: StaticString = #file,
        line: UInt = #line,
        factory: () -> UIViewController
    ) {
        for theme in snapshotThemes {
            XS2A.configure(
                withConfig: XS2A.Configuration(wizardSessionKey: "snapshot-test", baseURL: "http://localhost:0"),
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

            postLoad?(vc)

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
