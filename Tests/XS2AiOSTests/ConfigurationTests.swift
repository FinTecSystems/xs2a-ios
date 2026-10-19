import XCTest
@testable import XS2AiOS

final class ConfigurationTests: XCTestCase {

    // MARK: - Language selection

    func testExplicitLanguage_english() {
        let config = XS2A.Configuration(wizardSessionKey: "test", language: .en)
        XCTAssertEqual(config.language, .en)
    }

    func testExplicitLanguage_german() {
        let config = XS2A.Configuration(wizardSessionKey: "test", language: .de)
        XCTAssertEqual(config.language, .de)
    }

    func testExplicitLanguage_french() {
        let config = XS2A.Configuration(wizardSessionKey: "test", language: .fr)
        XCTAssertEqual(config.language, .fr)
    }

    func testExplicitLanguage_italian() {
        let config = XS2A.Configuration(wizardSessionKey: "test", language: .it)
        XCTAssertEqual(config.language, .it)
    }

    func testExplicitLanguage_spanish() {
        let config = XS2A.Configuration(wizardSessionKey: "test", language: .es)
        XCTAssertEqual(config.language, .es)
    }

    func testLanguageNil_resultsInSupportedLanguageOrGermanFallback() {
        // When language is nil the SDK picks from the device language or falls back to .de
        let config = XS2A.Configuration(wizardSessionKey: "test", language: nil)
        let supportedLanguages: [XS2A.Language] = [.de, .en, .fr, .it, .es]
        XCTAssertTrue(supportedLanguages.contains(config.language))
    }

    // MARK: - Language rawValues

    func testLanguageRawValues() {
        XCTAssertEqual(XS2A.Language.de.rawValue, "de")
        XCTAssertEqual(XS2A.Language.en.rawValue, "en")
        XCTAssertEqual(XS2A.Language.fr.rawValue, "fr")
        XCTAssertEqual(XS2A.Language.it.rawValue, "it")
        XCTAssertEqual(XS2A.Language.es.rawValue, "es")
    }

    func testLanguageRoundTrip_fromRawValue() {
        XCTAssertEqual(XS2A.Language(rawValue: "de"), .de)
        XCTAssertEqual(XS2A.Language(rawValue: "en"), .en)
        XCTAssertEqual(XS2A.Language(rawValue: "fr"), .fr)
        XCTAssertEqual(XS2A.Language(rawValue: "it"), .it)
        XCTAssertEqual(XS2A.Language(rawValue: "es"), .es)
    }

    func testLanguage_unknownRawValueReturnsNil() {
        XCTAssertNil(XS2A.Language(rawValue: "xx"))
        XCTAssertNil(XS2A.Language(rawValue: ""))
    }

    // MARK: - Default values

    func testDefaultBaseURL() {
        let config = XS2A.Configuration(wizardSessionKey: "test")
        XCTAssertEqual(config.baseURL, "https://api.xs2a.com/jsonp")
    }

    func testCustomBaseURL() {
        let config = XS2A.Configuration(wizardSessionKey: "test", baseURL: "https://staging.example.com/api")
        XCTAssertEqual(config.baseURL, "https://staging.example.com/api")
    }

    func testDefaultEnableBackButton_isTrue() {
        let config = XS2A.Configuration(wizardSessionKey: "test")
        XCTAssertTrue(config.enableBackButton)
    }

    func testDisableBackButton() {
        let config = XS2A.Configuration(wizardSessionKey: "test", enableBackButton: false)
        XCTAssertFalse(config.enableBackButton)
    }

    func testDefaultWithScrollView_isTrue() {
        let config = XS2A.Configuration(wizardSessionKey: "test")
        XCTAssertTrue(config.withScrollView)
    }

    func testWithScrollView_disabled() {
        let config = XS2A.Configuration(wizardSessionKey: "test", withScrollView: false)
        XCTAssertFalse(config.withScrollView)
    }

    func testDefaultShowPasswordVisiblityToggle_isTrue() {
        let config = XS2A.Configuration(wizardSessionKey: "test")
        XCTAssertTrue(config.showPasswordVisiblityToggle)
    }

    func testShowPasswordVisibilityToggle_disabled() {
        let config = XS2A.Configuration(wizardSessionKey: "test", showPasswordVisiblityToggle: false)
        XCTAssertFalse(config.showPasswordVisiblityToggle)
    }

    func testDefaultRedirectDeepLink_isNil() {
        let config = XS2A.Configuration(wizardSessionKey: "test")
        XCTAssertNil(config.redirectDeepLink)
    }

    func testCustomRedirectDeepLink() {
        let config = XS2A.Configuration(wizardSessionKey: "test", redirectDeepLink: "myapp://xs2a/return")
        XCTAssertEqual(config.redirectDeepLink, "myapp://xs2a/return")
    }

    func testWizardSessionKeyIsStored() {
        let key = "wsk_abc123XYZ"
        let config = XS2A.Configuration(wizardSessionKey: key)
        XCTAssertEqual(config.wizardSessionKey, key)
    }

    // MARK: - WizardStep rawValues

    func testWizardStepRawValues() {
        XCTAssertEqual(WizardStep.bank.rawValue, "bank")
        XCTAssertEqual(WizardStep.account.rawValue, "account")
        XCTAssertEqual(WizardStep.login.rawValue, "login")
        XCTAssertEqual(WizardStep.tan.rawValue, "tan")
    }

    func testWizardStep_fromRawValue() {
        XCTAssertEqual(WizardStep(rawValue: "bank"), .bank)
        XCTAssertEqual(WizardStep(rawValue: "account"), .account)
        XCTAssertEqual(WizardStep(rawValue: "login"), .login)
        XCTAssertEqual(WizardStep(rawValue: "tan"), .tan)
        XCTAssertNil(WizardStep(rawValue: "unknown"))
    }
}
