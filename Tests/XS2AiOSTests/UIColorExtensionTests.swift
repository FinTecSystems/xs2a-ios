import XCTest
import UIKit
@testable import XS2AiOS

final class UIColorExtensionTests: XCTestCase {

    // MARK: - 6-character hex (RGB)

    func testHex6_red_withHash() {
        let color = UIColor(hex: "#FF0000")
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        XCTAssertEqual(r, 1.0, accuracy: 0.01)
        XCTAssertEqual(g, 0.0, accuracy: 0.01)
        XCTAssertEqual(b, 0.0, accuracy: 0.01)
        XCTAssertEqual(a, 1.0, accuracy: 0.01)
    }

    func testHex6_green_withoutHash() {
        let color = UIColor(hex: "00FF00")
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        XCTAssertEqual(r, 0.0, accuracy: 0.01)
        XCTAssertEqual(g, 1.0, accuracy: 0.01)
        XCTAssertEqual(b, 0.0, accuracy: 0.01)
    }

    func testHex6_blue() {
        let color = UIColor(hex: "#0000FF")
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        XCTAssertEqual(r, 0.0, accuracy: 0.01)
        XCTAssertEqual(g, 0.0, accuracy: 0.01)
        XCTAssertEqual(b, 1.0, accuracy: 0.01)
    }

    func testHex6_black() {
        let color = UIColor(hex: "#000000")
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        XCTAssertEqual(r, 0.0, accuracy: 0.01)
        XCTAssertEqual(g, 0.0, accuracy: 0.01)
        XCTAssertEqual(b, 0.0, accuracy: 0.01)
        XCTAssertEqual(a, 1.0, accuracy: 0.01)
    }

    func testHex6_white() {
        let color = UIColor(hex: "#FFFFFF")
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        XCTAssertEqual(r, 1.0, accuracy: 0.01)
        XCTAssertEqual(g, 1.0, accuracy: 0.01)
        XCTAssertEqual(b, 1.0, accuracy: 0.01)
        XCTAssertEqual(a, 1.0, accuracy: 0.01)
    }

    func testHex6_defaultAlphaIs1() {
        let color = UIColor(hex: "#ABCDEF")
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        XCTAssertEqual(a, 1.0, accuracy: 0.01)
    }

    func testHex6_customDefaultAlpha() {
        let color = UIColor(hex: "#FF0000", defaultAlpha: 0.5)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        XCTAssertEqual(r, 1.0, accuracy: 0.01)
        XCTAssertEqual(a, 0.5, accuracy: 0.01)
    }

    // MARK: - 8-character hex (AARRGGBB)

    func testHex8_withFullAlpha() {
        // AARRGGBB format: AA=FF (full alpha), RR=FF (red=1), GG=00, BB=00
        let color = UIColor(hex: "FFFF0000")
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        XCTAssertEqual(r, 1.0, accuracy: 0.01)
        XCTAssertEqual(a, 1.0, accuracy: 0.01)
    }

    func testHex8_withHalfAlpha() {
        // AARRGGBB: AA=80 (~50% alpha), RR=FF (red=1), GG=00, BB=00
        let color = UIColor(hex: "80FF0000")
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        XCTAssertEqual(r, 1.0, accuracy: 0.01)
        XCTAssertEqual(a, CGFloat(0x80) / 255.0, accuracy: 0.01)
    }

    func testHex8_withZeroAlpha() {
        // AARRGGBB: AA=00 (transparent), RR=FF, GG=00, BB=00
        let color = UIColor(hex: "00FF0000")
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        XCTAssertEqual(a, 0.0, accuracy: 0.01)
    }

    // MARK: - Invalid / fallback

    func testInvalidHex_returnsNoErrorAndFallsBackToClear() {
        let color = UIColor(hex: "GGGGGG") // invalid hex chars
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        // Default fallback is .clear (alpha 0)
        XCTAssertEqual(a, 0.0, accuracy: 0.01)
    }

    func testEmptyHex_returnsNoErrorAndFallsBackToClear() {
        let color = UIColor(hex: "")
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        XCTAssertEqual(a, 0.0, accuracy: 0.01)
    }

    func testInvalidHex_usesCustomFallback() {
        let color = UIColor(hex: "ZZZZZZ", fallback: .red)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        XCTAssertEqual(r, 1.0, accuracy: 0.01)
        XCTAssertEqual(g, 0.0, accuracy: 0.01)
        XCTAssertEqual(b, 0.0, accuracy: 0.01)
    }

    // MARK: - Whitespace trimming

    func testWhitespaceTrimming_leadingAndTrailing() {
        let colorWithSpace = UIColor(hex: "  #FF0000  ")
        let colorClean     = UIColor(hex: "#FF0000")
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        colorWithSpace.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        colorClean.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        XCTAssertEqual(r1, r2, accuracy: 0.001)
        XCTAssertEqual(g1, g2, accuracy: 0.001)
        XCTAssertEqual(b1, b2, accuracy: 0.001)
        XCTAssertEqual(a1, a2, accuracy: 0.001)
    }

    // MARK: - Specific brand colours used in the SDK

    func testBrandTintColor() {
        // Default tint colour from StyleProvider: r=66 g=119 b=131
        let color = UIColor(hex: "#426377")
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        XCTAssertEqual(r, 66.0 / 255.0, accuracy: 0.005)
        XCTAssertEqual(g, 99.0 / 255.0, accuracy: 0.005)
        XCTAssertEqual(b, 119.0 / 255.0, accuracy: 0.005)
    }

    func testErrorColor() {
        let color = UIColor(hex: "#DB271A")
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        XCTAssertEqual(r, CGFloat(0xDB) / 255.0, accuracy: 0.005)
        XCTAssertEqual(g, CGFloat(0x27) / 255.0, accuracy: 0.005)
        XCTAssertEqual(b, CGFloat(0x1A) / 255.0, accuracy: 0.005)
    }
}
