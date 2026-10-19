import XCTest
@testable import XS2AiOS

final class AutocompleteViewSnapshotTests: SnapshotTestCase {

    private let snapshotSize = CGSize(width: 390, height: 600)

    // MARK: - test_empty

    /// Just opened: empty search field, italic info notice visible, result table hidden.
    func test_empty() {
        assertSnapshots(named: "AutocompleteView_empty", size: snapshotSize) {
            AutocompleteView(
                countryId: "DE",
                label: "Select your bank",
                prefilledText: nil
            )
        }
    }

    // MARK: - test_withResults

    /// Bank search returned results: table shows two rows with name/city and bank code/BIC.
    func test_withResults() {
        let sampleResults: [AutocompleteResult] = [
            AutocompleteResult(
                label: "Deutsche Bank Frankfurt",
                value: "DEUTDEDB",
                object: AutocompleteResultObject(
                    name: "Deutsche Bank",
                    city: "Frankfurt",
                    bank_code: "20070000",
                    bic: "DEUTDEDB"
                )
            ),
            AutocompleteResult(
                label: "Commerzbank Berlin",
                value: "COBADEFFXXX",
                object: AutocompleteResultObject(
                    name: "Commerzbank",
                    city: "Berlin",
                    bank_code: "20040060",
                    bic: "COBADEFFXXX"
                )
            ),
        ]

        assertSnapshots(
            named: "AutocompleteView_withResults",
            size: snapshotSize,
            postLoad: { vc in
                guard let autocompleteVC = vc as? AutocompleteView else { return }
                autocompleteVC.reloadTable(with: sampleResults)
            }
        ) {
            AutocompleteView(
                countryId: "DE",
                label: "Select your bank",
                prefilledText: nil
            )
        }
    }

    // MARK: - test_ibanTyping

    /// Partial IBAN typed: "still typing" info label visible, Next button hidden.
    /// "DE12" matches ^[a-zA-Z]{2}[0-9]{2} (starts as IBAN) but is too short to be valid.
    func test_ibanTyping() {
        assertSnapshots(named: "AutocompleteView_ibanTyping", size: snapshotSize) {
            AutocompleteView(
                countryId: "DE",
                label: "Select your bank",
                prefilledText: "DE12"
            )
        }
    }

    // MARK: - test_ibanValid

    /// Complete IBAN: Next button visible, info label hidden.
    /// "DE89370400440532013000" is 22 chars and matches [A-Z]{2}\d{2}[a-zA-Z0-9]{12,32}.
    func test_ibanValid() {
        assertSnapshots(named: "AutocompleteView_ibanValid", size: snapshotSize) {
            AutocompleteView(
                countryId: "DE",
                label: "Select your bank",
                prefilledText: "DE89370400440532013000"
            )
        }
    }
}
