# AutocompleteView Snapshot Tests Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add four snapshot test cases for `AutocompleteView` covering empty, with-results, IBAN-typing, and valid-IBAN states, each rendered in `defaultLight` and `defaultDark` themes.

**Architecture:** Extend the shared `SnapshotTestCase.assertSnapshots` helper with two optional backward-compatible parameters (`size` and `postLoad`), then create a new test file `AutocompleteViewSnapshotTests.swift` that exercises all four visual states.

**Tech Stack:** Swift 5, XCTest, [swift-snapshot-testing](https://github.com/pointfreeco/swift-snapshot-testing), Xcode (scheme `XS2AiOSSnapshotTests`)

## Global Constraints

- iOS deployment target: iOS 11
- Snapshot framework: `SnapshotTesting` (already in the project)
- All snapshots rendered at fixed size `CGSize(width: 390, height: 600)` for `AutocompleteView` tests
- Each test must produce two snapshots: `…_defaultLight` and `…_defaultDark`
- New parameters on `assertSnapshots` must be optional with defaults so **all existing call sites compile unchanged**
- Reference snapshots are recorded via `IS_RECORDING_SNAPSHOTS=YES` env var; first run without that flag will fail (expected — see Task 3)
- Test command: `xcodebuild test -project XS2AiOS.xcodeproj -scheme XS2AiOSSnapshotTests -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest'`

---

### Task 1: Extend `SnapshotTestCase` with `size` and `postLoad` parameters

**Files:**
- Modify: `Tests/XS2AiOSSnapshotTests/SnapshotTestCase.swift`

**Interfaces:**
- Produces:
  - `assertSnapshots(named:size:postLoad:file:line:factory:)` — updated signature with two new optional parameters
  - `size: CGSize? = nil` — when non-nil, skips intrinsic-height computation and uses this size directly
  - `postLoad: ((UIViewController) -> Void)? = nil` — called after `loadViewIfNeeded()` + `layoutIfNeeded()` and before the snapshot

- [ ] **Step 1: Open `SnapshotTestCase.swift` and update the `assertSnapshots` signature and body**

Replace the entire `assertSnapshots` function with:

```swift
func assertSnapshots(
    named testName: String,
    size: CGSize? = nil,
    postLoad: ((UIViewController) -> Void)? = nil,
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

        postLoad?(vc)

        let snapshotSize: CGSize
        if let fixedSize = size {
            snapshotSize = fixedSize
        } else {
            let fittingHeight = vc.view.systemLayoutSizeFitting(
                CGSize(width: 390, height: UIView.layoutFittingCompressedSize.height),
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel
            ).height
            snapshotSize = CGSize(width: 390, height: max(fittingHeight, 1))
        }

        let config = ViewImageConfig(
            safeArea: .zero,
            size: snapshotSize,
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
```

- [ ] **Step 2: Build the snapshot test target to confirm existing tests still compile**

Run:
```bash
xcodebuild build-for-testing \
  -project XS2AiOS.xcodeproj \
  -scheme XS2AiOSSnapshotTests \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' \
  | grep -E "error:|warning:|BUILD"
```

Expected: `BUILD SUCCEEDED` with no errors. No existing call sites should change.

- [ ] **Step 3: Commit**

```bash
git add Tests/XS2AiOSSnapshotTests/SnapshotTestCase.swift
git commit -m "test: extend assertSnapshots with optional size and postLoad parameters

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>"
```

---

### Task 2: Create `AutocompleteViewSnapshotTests.swift`

**Files:**
- Create: `Tests/XS2AiOSSnapshotTests/AutocompleteViewSnapshotTests.swift`

**Interfaces:**
- Consumes:
  - `assertSnapshots(named:size:postLoad:file:line:factory:)` from Task 1
  - `AutocompleteView(countryId:label:prefilledText:)` from `Sources/XS2AiOS/Utils/AutocompleteView.swift`
  - `AutocompleteResult(label:value:object:)` and `AutocompleteResultObject(name:city:bank_code:bic:)` from `Sources/XS2AiOS/Utils/APIService.swift`
  - `AutocompleteView.reloadTable(with:)` — public method that injects results into the table

- [ ] **Step 1: Create the file with all four test cases**

Create `Tests/XS2AiOSSnapshotTests/AutocompleteViewSnapshotTests.swift` with:

```swift
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
```

- [ ] **Step 2: Build to confirm the file compiles**

```bash
xcodebuild build-for-testing \
  -project XS2AiOS.xcodeproj \
  -scheme XS2AiOSSnapshotTests \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' \
  | grep -E "error:|warning:|BUILD"
```

Expected: `BUILD SUCCEEDED`.

- [ ] **Step 3: Commit**

```bash
git add Tests/XS2AiOSSnapshotTests/AutocompleteViewSnapshotTests.swift
git commit -m "test: add AutocompleteView snapshot tests (empty, withResults, ibanTyping, ibanValid)

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>"
```

---

### Task 3: Record reference snapshots

Reference images don't exist yet — the tests will fail on first run without the recording flag. This task records them.

**Files:**
- Creates (auto-generated): `Tests/XS2AiOSSnapshotTests/__Snapshots__/AutocompleteViewSnapshotTests/` (8 PNG files)

- [ ] **Step 1: Run the new tests in recording mode**

```bash
xcodebuild test \
  -project XS2AiOS.xcodeproj \
  -scheme XS2AiOSSnapshotTests \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' \
  -only-testing:XS2AiOSSnapshotTests/AutocompleteViewSnapshotTests \
  -testLanguage en \
  TEST_RUNNER_IS_RECORDING_SNAPSHOTS=YES \
  | grep -E "Test.*passed|Test.*failed|error:|Recorded"
```

Expected: 4 tests pass (recording always passes). Eight PNG files created under:
`Tests/XS2AiOSSnapshotTests/__Snapshots__/AutocompleteViewSnapshotTests/`

- [ ] **Step 2: Visually inspect the 8 generated snapshots**

Open the `__Snapshots__/AutocompleteViewSnapshotTests/` folder in Finder and verify each image:

| File | What to check |
|------|--------------|
| `AutocompleteView_empty_defaultLight.png` | Label, empty search field, italic notice text, no table rows |
| `AutocompleteView_empty_defaultDark.png` | Same content, dark background/text |
| `AutocompleteView_withResults_defaultLight.png` | Label, empty search field, 2 table rows (Deutsche Bank + Commerzbank) |
| `AutocompleteView_withResults_defaultDark.png` | Same content, dark |
| `AutocompleteView_ibanTyping_defaultLight.png` | Label, "DE12" in search field, italic "typing" notice, no Next button |
| `AutocompleteView_ibanTyping_defaultDark.png` | Same content, dark |
| `AutocompleteView_ibanValid_defaultLight.png` | Label, full IBAN in search field, Next button visible, no info label |
| `AutocompleteView_ibanValid_defaultDark.png` | Same content, dark |

If any snapshot looks wrong, fix the test data or init parameters in `AutocompleteViewSnapshotTests.swift`, re-record, and re-inspect.

- [ ] **Step 3: Run the tests without recording to confirm they pass**

```bash
xcodebuild test \
  -project XS2AiOS.xcodeproj \
  -scheme XS2AiOSSnapshotTests \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' \
  -only-testing:XS2AiOSSnapshotTests/AutocompleteViewSnapshotTests \
  | grep -E "Test.*passed|Test.*failed|error:"
```

Expected: `Test Suite 'AutocompleteViewSnapshotTests' passed` with 4 tests passing.

- [ ] **Step 4: Run the full snapshot suite to confirm nothing regressed**

```bash
xcodebuild test \
  -project XS2AiOS.xcodeproj \
  -scheme XS2AiOSSnapshotTests \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' \
  | grep -E "Test Suite.*passed|Test Suite.*failed|error:"
```

Expected: all existing snapshot tests still pass.

- [ ] **Step 5: Commit the reference snapshots**

```bash
git add Tests/XS2AiOSSnapshotTests/__Snapshots__/AutocompleteViewSnapshotTests/
git commit -m "test: record AutocompleteView reference snapshots

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>"
```
