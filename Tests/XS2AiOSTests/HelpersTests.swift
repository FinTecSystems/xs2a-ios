import XCTest
@testable import XS2AiOS

final class HelpersTests: XCTestCase {

    // MARK: - stringStartsAsIban

    func testStartsAsIban_validUppercasePrefix() {
        XCTAssertTrue(stringStartsAsIban(stringToTest: "DE89370400440532013000"))
    }

    func testStartsAsIban_validLowercasePrefix() {
        XCTAssertTrue(stringStartsAsIban(stringToTest: "de89370400440532013000"))
    }

    func testStartsAsIban_validMixedCasePrefix() {
        XCTAssertTrue(stringStartsAsIban(stringToTest: "Gb29NWBK60161331926819"))
    }

    func testStartsAsIban_lettersWithoutDigits() {
        XCTAssertFalse(stringStartsAsIban(stringToTest: "ABCD"))
    }

    func testStartsAsIban_digitsOnly() {
        XCTAssertFalse(stringStartsAsIban(stringToTest: "1234567890"))
    }

    func testStartsAsIban_empty() {
        XCTAssertFalse(stringStartsAsIban(stringToTest: ""))
    }

    func testStartsAsIban_twoLettersThenOneDigit() {
        // Needs two letters then TWO digits to match
        XCTAssertFalse(stringStartsAsIban(stringToTest: "DE8"))
    }

    func testStartsAsIban_twoLettersThenTwoDigits() {
        XCTAssertTrue(stringStartsAsIban(stringToTest: "DE89"))
    }

    // MARK: - stringContainsValidIban

    func testContainsValidIban_validGerman() {
        XCTAssertTrue(stringContainsValidIban(stringToTest: "DE89370400440532013000"))
    }

    func testContainsValidIban_validGB() {
        XCTAssertTrue(stringContainsValidIban(stringToTest: "GB29NWBK60161331926819"))
    }

    func testContainsValidIban_tooShortAccountPart() {
        // Requires at least 12 alphanumeric chars after the check digits
        XCTAssertFalse(stringContainsValidIban(stringToTest: "DE8937040044"))
    }

    func testContainsValidIban_empty() {
        XCTAssertFalse(stringContainsValidIban(stringToTest: ""))
    }

    func testContainsValidIban_plainText() {
        XCTAssertFalse(stringContainsValidIban(stringToTest: "Hello World"))
    }

    func testContainsValidIban_embeddedInText() {
        XCTAssertTrue(stringContainsValidIban(stringToTest: "My IBAN is DE89370400440532013000 thanks"))
    }

    // MARK: - getRegexMatches

    func testGetRegexMatches_singleMatch() {
        let matches = getRegexMatches(for: "[0-9]+", in: "abc123def")
        XCTAssertEqual(matches.count, 1)
    }

    func testGetRegexMatches_noMatch() {
        let matches = getRegexMatches(for: "[0-9]+", in: "abcdef")
        XCTAssertEqual(matches.count, 0)
    }

    func testGetRegexMatches_multipleMatches() {
        let matches = getRegexMatches(for: "[0-9]+", in: "abc123def456ghi789")
        XCTAssertEqual(matches.count, 3)
    }

    func testGetRegexMatches_invalidPatternReturnsEmpty() {
        // An invalid regex should not crash; it returns an empty array
        let matches = getRegexMatches(for: "[invalid", in: "test")
        XCTAssertEqual(matches.count, 0)
    }

    func testGetRegexMatches_emptyInput() {
        let matches = getRegexMatches(for: "[0-9]+", in: "")
        XCTAssertEqual(matches.count, 0)
    }

    // MARK: - splitStringToGroups

    func testSplitStringToGroups_plainText() {
        let groups = splitStringToGroups(stringToTest: "Hello World")
        XCTAssertEqual(groups, ["Hello World"])
    }

    func testSplitStringToGroups_singleMarkupToken() {
        let groups = splitStringToGroups(stringToTest: "[br]")
        XCTAssertEqual(groups, ["[br]"])
    }

    func testSplitStringToGroups_textWithLinebreak() {
        let groups = splitStringToGroups(stringToTest: "Hello [br] World")
        XCTAssertTrue(groups.contains("[br]"))
        XCTAssertTrue(groups.count > 1)
    }

    func testSplitStringToGroups_textWithBoldMarkup() {
        let groups = splitStringToGroups(stringToTest: "Hello [bold text|bold] World")
        XCTAssertTrue(groups.contains("[bold text|bold]"))
        XCTAssertEqual(groups.count, 3)
    }

    func testSplitStringToGroups_multipleMarkupTokens() {
        let input = "Before [link|link::http://example.com] middle [note|bold] after"
        let groups = splitStringToGroups(stringToTest: input)
        XCTAssertTrue(groups.contains("[link|link::http://example.com]"))
        XCTAssertTrue(groups.contains("[note|bold]"))
        XCTAssertGreaterThanOrEqual(groups.count, 3)
    }

    func testSplitStringToGroups_onlyMarkup() {
        let groups = splitStringToGroups(stringToTest: "[text|italic]")
        XCTAssertEqual(groups, ["[text|italic]"])
    }

    func testSplitStringToGroups_emptyString() {
        let groups = splitStringToGroups(stringToTest: "")
        XCTAssertEqual(groups.count, 0)
    }
}
