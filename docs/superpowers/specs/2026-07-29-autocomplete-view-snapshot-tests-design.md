# AutocompleteView Snapshot Tests — Design

**Date:** 2026-07-29  
**Status:** Approved

## Overview

Add screenshot (snapshot) tests for `AutocompleteView`, the modal UIViewController that lets users search for a bank by name/code or enter an IBAN manually. Tests use the existing `SnapshotTesting` infrastructure and cover four distinct visual states, each rendered in `defaultLight` and `defaultDark` themes.

## Files Changed

| File | Change |
|------|--------|
| `Tests/XS2AiOSSnapshotTests/SnapshotTestCase.swift` | Extend `assertSnapshots` with optional `size` and `postLoad` parameters |
| `Tests/XS2AiOSSnapshotTests/AutocompleteViewSnapshotTests.swift` | New file with 4 test cases |

## SnapshotTestCase Extension

`assertSnapshots` gains two optional parameters (both default to `nil`, so all existing call sites are unaffected):

```swift
func assertSnapshots(
    named testName: String,
    size: CGSize? = nil,
    postLoad: ((UIViewController) -> Void)? = nil,
    file: StaticString = #file,
    line: UInt = #line,
    factory: () -> UIViewController
)
```

- **`size`** — when provided, the snapshot uses this fixed size instead of computing the intrinsic height. Needed because `AutocompleteView` embeds a `resultTable` with a `UIScreen.main.bounds.height` fixed-height constraint.
- **`postLoad`** — called after `loadViewIfNeeded()` / `layoutIfNeeded()` but before the snapshot is taken. Used to inject table data without going through the network.

## Test Cases

All four tests use `size: CGSize(width: 390, height: 600)`.

### test_empty
- Init: `AutocompleteView(countryId: "DE", label: "Select your bank", prefilledText: nil)`
- Expected visual: label at top, empty search field, italic info notice ("Please enter your bank name or IBAN"), result table hidden.

### test_withResults
- Init: same as `test_empty`
- `postLoad`: call `reloadTable(with: [sampleBankResult1, sampleBankResult2])` where the sample data is:
  - Deutsche Bank, Frankfurt, bank code `200 700 00`, BIC `DEUTDEDB`
  - Commerzbank, Berlin, bank code `200 400 60`, BIC `COBADEFFXXX`
- Expected visual: label, search field, table showing two rows (bank name + city on line 1, bank code + BIC on line 2).

### test_ibanTyping
- Init: `AutocompleteView(countryId: "DE", label: "Select your bank", prefilledText: "DE12")`
- Expected visual: label, search field with "DE12", italic "still typing" info label, Next button hidden.

### test_ibanValid
- Init: `AutocompleteView(countryId: "DE", label: "Select your bank", prefilledText: "DE89370400440532013000")`
- Expected visual: label, search field with valid IBAN, Next button visible, info label hidden.

## Snapshot Output

Each test produces 2 snapshot files:
- `<TestName>_defaultLight`
- `<TestName>_defaultDark`

Stored in `Tests/XS2AiOSSnapshotTests/__Snapshots__/AutocompleteViewSnapshotTests/`.

## Constraints and Notes

- The API call in `viewDidLoad` (`getAutocompleteResults`) is async and fires after layout completes; it does not affect snapshot output.
- `searchField.becomeFirstResponder()` is called in `viewDidLoad` but does not affect snapshot rendering.
- Snapshots are recorded on first run (controlled by `IS_RECORDING_SNAPSHOTS=YES` env var, per the existing convention in `SnapshotTestCase.setUp`).
