# Snapshot Testing Design

## Problem

There is no visual regression testing for XS2AiOS UI components. When styling or layout changes are made, regressions can go undetected. This spec defines an automated snapshot test suite using `swift-snapshot-testing` that verifies every visible form line component across all supported themes.

## Approach

- **Framework**: [swift-snapshot-testing](https://github.com/pointfreeco/swift-snapshot-testing) (Point-Free), added as a Swift Package dependency
- **Scope**: Individual form line `UIViewController` subclasses, rendered in isolation at a fixed width (390pt, matching iPhone 16/17 logical width)
- **Themes**: Looped automatically — each component test is written once and runs for every theme
- **Golden images**: PNG files committed to the repository, tracked via Git LFS
- **CI**: A dedicated `snapshot-tests` job in the existing GitHub Actions workflow

---

## Themes

Two `StyleProvider` instances are defined in the test target:

| Name | Description |
|------|-------------|
| `defaultLight` | The default `StyleProvider()` initializer with light background colors |
| `defaultDark` | A custom `StyleProvider` with dark background (`#1C1C1E`), light text, and adjusted input/button colors |

Each theme is represented as a `(name: String, styleProvider: XS2A.StyleProvider)` tuple stored in a `themes` array on the base test class.

---

## Architecture

### New Xcode Test Target

A new test target `XS2AiOSSnapshotTests` is added to `XS2AiOS.xcodeproj`, separate from the existing `XS2AiOSTests`. This keeps snapshot tests isolated from unit tests and allows them to be run or skipped independently in CI.

### Base Test Class: `SnapshotTestCase`

```
Tests/XS2AiOSSnapshotTests/
  SnapshotTestCase.swift          ← Base class: themes array + assertSnapshots helper
  Themes.swift                    ← Theme definitions (light + dark StyleProviders)
  FormLines/
    TextLineSnapshotTests.swift
    PasswordLineSnapshotTests.swift
    CheckboxLineSnapshotTests.swift
    RadioLineSnapshotTests.swift
    SelectLineSnapshotTests.swift
    SubmitLineSnapshotTests.swift
    ParagraphLineSnapshotTests.swift
    DescriptionLineSnapshotTests.swift
    CaptchaLineSnapshotTests.swift
    FlickerLineSnapshotTests.swift
    ImageLineSnapshotTests.swift
    TabLineSnapshotTests.swift
    RestartLineSnapshotTests.swift
    RedirectLineSnapshotTests.swift
```

### `SnapshotTestCase` base class responsibilities:

1. Holds a `themes: [(name: String, style: XS2A.StyleProvider)]` array
2. Provides `assertSnapshots(name: String, factory: (String) -> UIViewController)` — for each theme:
   - Calls `XS2A.configure(withConfig:withStyle:)` with a dummy session key and the theme's `StyleProvider`
   - Instantiates the VC via `factory`
   - Embeds it in a fixed-width `UIWindow` (390 × `UIView.layoutFittingCompressedSize.height`)
   - Triggers `viewDidLoad()` and layout
   - Calls `assertSnapshot(matching:as:.image, named: "\(name)_\(themeName)")` from `swift-snapshot-testing`

The `factory` closure receives the theme name as a `String` parameter so tests can use it for snapshot naming if needed.

### Example test (one method covers all themes automatically):

```swift
func testTextLine_default() {
    assertSnapshots(name: "TextLine_default") { _ in
        TextLine(
            name: "account",
            label: "Account Number",
            disabled: false,
            invalid: false,
            autocompleteAction: nil,
            value: "",
            placeholder: "Enter account number",
            index: 0,
            isLoginCredential: false,
            isRequired: false,
            errorMessage: nil
        )
    }
}
```

Multiple test methods per component capture meaningful states (default, invalid, disabled, required).

---

## Components Covered

| Component | States to test |
|-----------|---------------|
| `TextLine` | default, invalid, required, disabled |
| `PasswordLine` | default, invalid, required |
| `CheckboxLine` | unchecked, checked, invalid |
| `RadioLine` | default (first option pre-selected) |
| `SelectLine` | default (no selection), with selection, invalid |
| `SubmitLine` | submit button, back button, abort button |
| `ParagraphLine` | none severity, info, warning, error |
| `DescriptionLine` | plain text |
| `CaptchaLine` | with a static base64-encoded test image |
| `FlickerLine` | default — snapshot captures the initial state (all blocks white) before the animation timer fires |
| `ImageLine` | with a static base64-encoded test image |
| `TabLine` | default |
| `RestartLine` | default |
| `RedirectLine` | default |

**Excluded:** `LogoLine` — loads a PDF from a remote URL, making it unreliable in CI. `HiddenLine` and `AutosubmitLine` — no visible UI to snapshot.

---

## Git LFS Setup

### `.gitattributes`

Track only PNG files inside the snapshot output directory to avoid LFS overhead on all project images:

```
Tests/XS2AiOSSnapshotTests/**/__Snapshots__/**/*.png filter=lfs diff=lfs merge=lfs -text
```

### Initialization

`git lfs install` must be run once in the repo. The CI runner (`macos-latest`) has `git-lfs` pre-installed; no extra step is needed in the workflow.

---

## CI Integration

A new `snapshot-tests` job is added to `.github/workflows/ci.yml`:

```yaml
snapshot-tests:
  runs-on: macos-latest
  steps:
    - uses: actions/checkout@v7
      with:
        lfs: true          # pull LFS objects (golden images)
    - name: Run snapshot tests
      run: |
        xcodebuild test \
          -project XS2AiOS.xcodeproj \
          -scheme XS2AiOSSnapshotTests \
          -destination 'platform=iOS Simulator,name=iPhone 17' \
          CODE_SIGN_IDENTITY="" \
          CODE_SIGNING_REQUIRED=NO \
          CODE_SIGNING_ALLOWED=NO
```

Note: `lfs: true` on the checkout action ensures golden images are fetched rather than just their LFS pointer files.

---

## Recording Golden Images: CI Workflow

Following the pattern used by the sibling `xs2a-android` SDK, golden images are **generated and committed by CI**, not by developers locally. A dedicated `workflow_dispatch` workflow (`record-screenshots.yml`) handles this.

### Workflow: `record-screenshots.yml`

- **Trigger**: Manual (`workflow_dispatch`), with a `branch` input parameter
- **Runner**: `macos-latest` (required for iOS Simulator)
- **Permissions**: `contents: write` (to push the commit back)

**Steps:**
1. `actions/checkout@v7` — checks out the target branch with `lfs: true`
2. `git lfs install` — ensures LFS filters are active so new PNGs are stored as LFS objects
3. Run `xcodebuild test` with `IS_RECORDING_SNAPSHOTS=YES` as a build setting — this sets `isRecording = true` on the base test class, causing `swift-snapshot-testing` to write new golden images instead of comparing
4. Commit updated golden images back to the branch with message `chore: update screenshot golden images [skip ci]`
5. Push to origin

### `IS_RECORDING_SNAPSHOTS` build setting

The `SnapshotTestCase` base class reads a build setting (via a key in `Info.plist` or directly from the environment) to determine whether to record or verify:

```swift
// In SnapshotTestCase.setUp():
isRecording = ProcessInfo.processInfo.environment["IS_RECORDING_SNAPSHOTS"] == "YES"
```

The `xcodebuild` command in the record workflow passes this via `-testenv IS_RECORDING_SNAPSHOTS=YES`.

### Workflow: When to trigger

Trigger `record-screenshots.yml` on the branch that contains intentional UI changes. The updated goldens are auto-committed, and the subsequent verify run (normal CI push) will pass.

---

## Pixel Precision

`swift-snapshot-testing` uses pixel-exact comparison by default. This is acceptable because:
- Tests run on a fixed simulator model (`iPhone 17`) in both local development and CI
- The `macos-latest` runner is kept consistent by GitHub
- If rendering differences appear across Xcode versions, `perceptuallyCompare` or a custom `Diffing` strategy can be adopted

---

## Package Dependency

Added to `Package.swift` test dependencies (and to the Xcode target via the `.xcodeproj`):

```swift
.package(
    url: "https://github.com/pointfreeco/swift-snapshot-testing.git",
    from: "1.17.0"
)
```

The target imports `SnapshotTesting`.
