import XCTest
import SwiftyJSON
@testable import XS2AiOS

/// Tests for the core JSON → FormLine decoding logic in ResponseDecoder.swift.
///
/// All tests configure `XS2A.shared` before execution because form-line
/// initialisers access the shared style provider.
final class ResponseDecoderTests: XCTestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
        XS2A.configure(
            withConfig: XS2A.Configuration(wizardSessionKey: "test-wsk"),
            withStyle: XS2A.StyleProvider()
        )
    }

    // MARK: - Helpers

    /// Builds a minimal JSON payload that `decodeJSON` can consume.
    private func payload(
        form: [[String: Any]],
        callback: String = "bank",
        step: String = "bank"
    ) -> JSON {
        return JSON(["form": form, "callback": callback, "step": step])
    }

    // MARK: - Single form-type dispatch

    func testDecodeJSON_textType() {
        let json = payload(form: [[
            "type": "text", "name": "bank_code", "label": "Bank Code",
            "disabled": false, "invalid": false, "autocomplete_action": "",
            "value": "", "placeholder": "Enter bank code",
            "login_credential": false
        ]])
        let lines = decodeJSON(json: json)
        XCTAssertEqual(lines.count, 1)
        XCTAssertTrue(lines[0] is TextLine)
    }

    func testDecodeJSON_passwordType() {
        let json = payload(form: [[
            "type": "password", "name": "pin", "label": "PIN",
            "disabled": false, "placeholder": "Enter PIN",
            "invalid": false, "login_credential": true
        ]])
        let lines = decodeJSON(json: json)
        XCTAssertEqual(lines.count, 1)
        XCTAssertTrue(lines[0] is PasswordLine)
    }

    func testDecodeJSON_selectType_withArrayOptions() {
        let json = payload(form: [[
            "type": "select", "name": "country", "label": "Country",
            "options": ["DE", "AT", "CH"], "selected": "DE", "invalid": false
        ]])
        let lines = decodeJSON(json: json)
        XCTAssertEqual(lines.count, 1)
        XCTAssertTrue(lines[0] is SelectLine)
    }

    func testDecodeJSON_selectType_withDictionaryOptions() {
        let json = payload(form: [[
            "type": "select", "name": "country", "label": "Country",
            "options": ["0": "DE", "1": "AT"], "selected": "0", "invalid": false
        ]])
        let lines = decodeJSON(json: json)
        XCTAssertEqual(lines.count, 1)
        XCTAssertTrue(lines[0] is SelectLine)
    }

    func testDecodeJSON_descriptionType() {
        let json = payload(form: [[
            "type": "description", "text": "Please enter your credentials"
        ]])
        let lines = decodeJSON(json: json)
        XCTAssertEqual(lines.count, 1)
        XCTAssertTrue(lines[0] is DescriptionLine)
    }

    func testDecodeJSON_paragraphType_info() {
        let json = payload(form: [[
            "type": "paragraph", "title": "Notice", "text": "Everything is fine",
            "severity": "info"
        ]])
        let lines = decodeJSON(json: json)
        XCTAssertEqual(lines.count, 1)
        XCTAssertTrue(lines[0] is ParagraphLine)
    }

    func testDecodeJSON_paragraphType_warning() {
        let json = payload(form: [[
            "type": "paragraph", "title": "", "text": "Watch out",
            "severity": "warning"
        ]])
        let lines = decodeJSON(json: json)
        XCTAssertEqual(lines.count, 1)
        XCTAssertTrue(lines[0] is ParagraphLine)
    }

    func testDecodeJSON_checkboxType() {
        let json = payload(form: [[
            "type": "checkbox", "label": "I agree to the terms",
            "checked": false, "name": "terms",
            "disabled": false, "invalid": false, "required": false
        ]])
        let lines = decodeJSON(json: json)
        XCTAssertEqual(lines.count, 1)
        XCTAssertTrue(lines[0] is CheckboxLine)
    }

    func testDecodeJSON_captchaType() {
        let json = payload(form: [[
            "type": "captcha", "name": "captcha_answer", "label": "Enter code",
            "data": "", "placeholder": "Type the code",
            "invalid": false
        ]])
        let lines = decodeJSON(json: json)
        XCTAssertEqual(lines.count, 1)
        XCTAssertTrue(lines[0] is CaptchaLine)
    }

    func testDecodeJSON_hiddenType() {
        let json = payload(form: [[
            "type": "hidden", "name": "csrf_token", "value": "secret-abc"
        ]])
        let lines = decodeJSON(json: json)
        XCTAssertEqual(lines.count, 1)
        XCTAssertTrue(lines[0] is HiddenLine)
    }

    func testDecodeJSON_autosubmitType() {
        let json = payload(form: [["type": "autosubmit", "interval": 3]])
        let lines = decodeJSON(json: json)
        XCTAssertEqual(lines.count, 1)
        XCTAssertTrue(lines[0] is AutosubmitLine)
    }

    func testDecodeJSON_imageType() {
        let json = payload(form: [[
            "type": "image", "data": "data:image/png;base64,abc=",
            "description": "QR Code"
        ]])
        let lines = decodeJSON(json: json)
        XCTAssertEqual(lines.count, 1)
        XCTAssertTrue(lines[0] is ImageLine)
    }

    func testDecodeJSON_logoType() {
        let json = payload(form: [["type": "logo"]])
        let lines = decodeJSON(json: json)
        XCTAssertEqual(lines.count, 1)
        XCTAssertTrue(lines[0] is LogoLine)
    }

    func testDecodeJSON_radioType_stringOptions() {
        let json = payload(form: [[
            "type": "radio", "label": "Choose one", "name": "choice",
            "checked": 0, "options": ["Option A", "Option B"]
        ]])
        let lines = decodeJSON(json: json)
        XCTAssertEqual(lines.count, 1)
        XCTAssertTrue(lines[0] is RadioLine)
    }

    func testDecodeJSON_tabsType() {
        let json = payload(form: [[
            "type": "tabs", "selected": "tab1",
            "tabs": ["tab1": "Tab One", "tab2": "Tab Two"]
        ]])
        let lines = decodeJSON(json: json)
        XCTAssertEqual(lines.count, 1)
        XCTAssertTrue(lines[0] is TabLine)
    }

    func testDecodeJSON_flickerType() {
        let json = payload(form: [[
            "type": "flicker", "name": "flicker_code", "label": "Flicker",
            "code": [[1, 0, 1], [0, 1, 0]], "invalid": false, "placeholder": ""
        ]])
        let lines = decodeJSON(json: json)
        XCTAssertEqual(lines.count, 1)
        XCTAssertTrue(lines[0] is FlickerLine)
    }

    // MARK: - Submit / abort / restart / redirect

    func testDecodeJSON_submitType_noBack() {
        let json = payload(form: [["type": "submit", "label": "Continue"]])
        let lines = decodeJSON(json: json)
        XCTAssertEqual(lines.count, 1)
        XCTAssertTrue(lines[0] is SubmitLine)
    }

    func testDecodeJSON_submitType_withBack_addsBackButton() {
        let json = payload(form: [[
            "type": "submit", "label": "Continue", "back": "Back"
        ]])
        let lines = decodeJSON(json: json)
        // submit + back button, both SubmitLine
        XCTAssertEqual(lines.count, 2)
        XCTAssertTrue(lines[0] is SubmitLine)
        XCTAssertTrue(lines[1] is SubmitLine)
    }

    func testDecodeJSON_submitType_withBack_backButtonPresentFlag() {
        let json = payload(form: [[
            "type": "submit", "label": "Continue", "back": "Back"
        ]])
        _ = decodeJSON(json: json)
        XCTAssertTrue(XS2A.shared.backButtonIsPresent)
    }

    func testDecodeJSON_submitType_noBack_backButtonPresentFlagFalse() {
        let json = payload(form: [["type": "submit", "label": "Continue"]])
        _ = decodeJSON(json: json)
        XCTAssertFalse(XS2A.shared.backButtonIsPresent)
    }

    func testDecodeJSON_abortType() {
        let json = payload(form: [["type": "abort", "label": "Cancel"]])
        let lines = decodeJSON(json: json)
        XCTAssertEqual(lines.count, 1)
        XCTAssertTrue(lines[0] is SubmitLine)
    }

    func testDecodeJSON_restartType() {
        let json = payload(form: [["type": "restart", "label": "Restart"]])
        let lines = decodeJSON(json: json)
        XCTAssertEqual(lines.count, 1)
        XCTAssertTrue(lines[0] is RestartLine)
    }

    func testDecodeJSON_redirectType() {
        let json = payload(form: [[
            "type": "redirect", "label": "Continue to bank",
            "url": "https://bank.example.com/auth"
        ]])
        let lines = decodeJSON(json: json)
        XCTAssertEqual(lines.count, 1)
        XCTAssertTrue(lines[0] is RedirectLine)
    }

    func testDecodeJSON_redirectType_withBack() {
        let json = payload(form: [[
            "type": "redirect", "label": "Continue to bank",
            "url": "https://bank.example.com/auth", "back": "Go back"
        ]])
        let lines = decodeJSON(json: json)
        XCTAssertEqual(lines.count, 2)
        XCTAssertTrue(lines[0] is RedirectLine)
        XCTAssertTrue(lines[1] is SubmitLine)
    }

    // MARK: - Unknown type

    func testDecodeJSON_unknownTypeIsSkipped() {
        let json = payload(form: [["type": "totally_unknown_element", "label": "?"]])
        let lines = decodeJSON(json: json)
        XCTAssertEqual(lines.count, 0)
    }

    func testDecodeJSON_mixedKnownAndUnknownTypes() {
        let json = payload(form: [
            ["type": "description", "text": "Welcome"],
            ["type": "unknown_future_type", "label": "?"],
            ["type": "logo"]
        ])
        let lines = decodeJSON(json: json)
        XCTAssertEqual(lines.count, 2)
    }

    // MARK: - Mixed form

    func testDecodeJSON_mixedTypes_countMatchesKnownElements() {
        let json = payload(form: [
            ["type": "description", "text": "Intro"],
            ["type": "text", "name": "f1", "label": "Field", "disabled": false,
             "invalid": false, "autocomplete_action": "", "value": "", "placeholder": ""],
            ["type": "submit", "label": "Go"]
        ])
        let lines = decodeJSON(json: json)
        XCTAssertEqual(lines.count, 3)
    }

    // MARK: - Wizard state and step

    func testDecodeJSON_setsCurrentState() {
        let json = payload(form: [], callback: "bank", step: "login_step")
        _ = decodeJSON(json: json)
        XCTAssertEqual(XS2A.shared.currentState, "login_step")
    }

    func testDecodeJSON_setsCurrentStep_bank() {
        let json = payload(form: [], callback: "bank", step: "bank")
        _ = decodeJSON(json: json)
        XCTAssertEqual(XS2A.shared.currentStep, .bank)
    }

    func testDecodeJSON_setsCurrentStep_login() {
        let json = payload(form: [], callback: "login", step: "login")
        _ = decodeJSON(json: json)
        XCTAssertEqual(XS2A.shared.currentStep, .login)
    }

    func testDecodeJSON_setsCurrentStep_account() {
        let json = payload(form: [], callback: "account", step: "account")
        _ = decodeJSON(json: json)
        XCTAssertEqual(XS2A.shared.currentStep, .account)
    }

    func testDecodeJSON_setsCurrentStep_tan() {
        let json = payload(form: [], callback: "tan", step: "tan")
        _ = decodeJSON(json: json)
        XCTAssertEqual(XS2A.shared.currentStep, .tan)
    }

    func testDecodeJSON_unknownCallbackClearsCurrentStep() {
        // WizardStep(rawValue:) returns nil for unknown values.
        // The decoder still assigns this nil to currentStep, clearing any prior value.
        XS2A.shared.currentStep = .bank
        let json = payload(form: [], callback: "some_unknown_callback", step: "unknown")
        _ = decodeJSON(json: json)
        XCTAssertNil(XS2A.shared.currentStep, "Unknown callback should clear currentStep")
    }

    // MARK: - filterFormElements (error-deduplication, exercised indirectly)

    func testFilterFormElements_errorParagraphMatchingInlineError_isRemoved() {
        // An error-severity paragraph whose text matches an inline field's `errorMessage`
        // should be suppressed to avoid showing the same message twice.
        let json = payload(form: [
            [
                "type": "text", "name": "bank_code", "label": "Bank Code",
                "disabled": false, "invalid": true, "autocomplete_action": "",
                "value": "", "placeholder": "", "validation_error": "Field is required"
            ],
            [
                "type": "paragraph", "title": "", "text": "Field is required",
                "severity": "error"
            ]
        ])
        let lines = decodeJSON(json: json)
        let paragraphs = lines.filter { $0 is ParagraphLine }
        XCTAssertEqual(paragraphs.count, 0, "Error paragraph should be suppressed when the same text appears as an inline field error")
    }

    func testFilterFormElements_nonErrorParagraph_isKeptEvenWithMatchingInlineError() {
        // An info/warning-severity paragraph is never considered an "error" duplicate
        // and must be kept regardless of inline field errors.
        let json = payload(form: [
            [
                "type": "text", "name": "bank_code", "label": "Bank Code",
                "disabled": false, "invalid": true, "autocomplete_action": "",
                "value": "", "placeholder": "", "validation_error": "Field is required"
            ],
            [
                "type": "paragraph", "title": "Note", "text": "Field is required",
                "severity": "info"
            ]
        ])
        let lines = decodeJSON(json: json)
        let paragraphs = lines.filter { $0 is ParagraphLine }
        XCTAssertEqual(paragraphs.count, 1, "Non-error paragraph should not be filtered")
    }

    func testFilterFormElements_errorParagraphWithNonMatchingText_isKept() {
        // An error paragraph whose text does NOT match any inline field error stays.
        let json = payload(form: [
            [
                "type": "text", "name": "bank_code", "label": "Bank Code",
                "disabled": false, "invalid": true, "autocomplete_action": "",
                "value": "", "placeholder": "", "validation_error": "A different error"
            ],
            [
                "type": "paragraph", "title": "", "text": "Field is required",
                "severity": "error"
            ]
        ])
        let lines = decodeJSON(json: json)
        let paragraphs = lines.filter { $0 is ParagraphLine }
        XCTAssertEqual(paragraphs.count, 1, "Error paragraph with unique text should be kept")
    }

    func testFilterFormElements_errorParagraphWithNoFields_isKept() {
        // An error paragraph with no other form elements should always be kept.
        let json = payload(form: [[
            "type": "paragraph", "title": "Error", "text": "Session expired",
            "severity": "error"
        ]])
        let lines = decodeJSON(json: json)
        let paragraphs = lines.filter { $0 is ParagraphLine }
        XCTAssertEqual(paragraphs.count, 1)
    }
}
