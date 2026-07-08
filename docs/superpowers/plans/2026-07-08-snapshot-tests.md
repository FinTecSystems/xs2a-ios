# Snapshot Tests Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add automated visual regression snapshot tests for all XS2AiOS form line UI components, run in CI against golden PNG images stored via Git LFS, with a `workflow_dispatch` CI workflow to regenerate goldens when UI intentionally changes.

**Architecture:** A new `XS2AiOSSnapshotTests` Xcode test target uses `swift-snapshot-testing` (Point-Free) to render each `UIViewController` form line in isolation at 390pt width. A `SnapshotTestCase` base class holds a `themes` array and a helper that loops over every theme for each test — each component test is written once and runs for both default-light and default-dark themes automatically.

**Tech Stack:** `swift-snapshot-testing` 1.17.0+, `xcodeproj` Ruby gem, Xcode + `xcodebuild`, Git LFS, GitHub Actions.

## Global Constraints

- iOS deployment target: 11.0 (matches `XS2AiOS` main target)
- Swift version: 5.0
- Snapshot width: 390pt (logical width of iPhone 16/17)
- Simulator: `iPhone 17` (matching existing CI `unit-tests` job)
- Golden images: stored in `Tests/XS2AiOSSnapshotTests/**/__Snapshots__/**/*.png`, tracked by Git LFS
- Form lines excluded from tests: `LogoLine` (network-dependent), `HiddenLine`, `AutosubmitLine` (no UI)
- `XS2A.configure()` must be called before any form line is instantiated — always called in `setUp()` with `wizardSessionKey: "snapshot-test"`
- `isRecording` controlled via environment variable `IS_RECORDING_SNAPSHOTS=YES` (set by the record workflow)

---

### Task 1: Git LFS Setup

**Files:**
- Create: `.gitattributes`

**Interfaces:**
- Produces: LFS tracking rule for snapshot PNGs; consumed by Tasks 5–10 (once PNGs are committed)

- [ ] **Step 1: Install Git LFS in the repository**

```bash
git lfs install
```

Expected output: `Git LFS initialized.`

- [ ] **Step 2: Create `.gitattributes`**

Create the file `.gitattributes` at the repository root:

```
Tests/XS2AiOSSnapshotTests/**/__Snapshots__/**/*.png filter=lfs diff=lfs merge=lfs -text
```

- [ ] **Step 3: Verify LFS tracks the pattern**

```bash
git lfs track
```

Expected output includes:
```
Listing tracked patterns
    Tests/XS2AiOSSnapshotTests/**/__Snapshots__/**/*.png (.gitattributes)
```

- [ ] **Step 4: Commit**

```bash
git add .gitattributes
git commit -m "chore: configure Git LFS for snapshot golden images"
```

---

### Task 2: Add Xcode Test Target and SPM Dependency

**Files:**
- Create: `scripts/add_snapshot_target.rb` (temporary — deleted after use)
- Modify: `XS2AiOS.xcodeproj/project.pbxproj` (via Ruby script)
- Create: `XS2AiOS.xcodeproj/xcshareddata/xcschemes/XS2AiOSSnapshotTests.xcscheme`
- Create (stub, empty): `Tests/XS2AiOSSnapshotTests/SnapshotTestCase.swift`
- Create (stub, empty): `Tests/XS2AiOSSnapshotTests/Themes.swift`
- Create (stub, empty): `Tests/XS2AiOSSnapshotTests/FormLines/TextLineSnapshotTests.swift`
- Create (stub, empty): `Tests/XS2AiOSSnapshotTests/FormLines/PasswordLineSnapshotTests.swift`
- Create (stub, empty): `Tests/XS2AiOSSnapshotTests/FormLines/CheckboxLineSnapshotTests.swift`
- Create (stub, empty): `Tests/XS2AiOSSnapshotTests/FormLines/RadioLineSnapshotTests.swift`
- Create (stub, empty): `Tests/XS2AiOSSnapshotTests/FormLines/SelectLineSnapshotTests.swift`
- Create (stub, empty): `Tests/XS2AiOSSnapshotTests/FormLines/SubmitLineSnapshotTests.swift`
- Create (stub, empty): `Tests/XS2AiOSSnapshotTests/FormLines/ParagraphLineSnapshotTests.swift`
- Create (stub, empty): `Tests/XS2AiOSSnapshotTests/FormLines/DescriptionLineSnapshotTests.swift`
- Create (stub, empty): `Tests/XS2AiOSSnapshotTests/FormLines/CaptchaLineSnapshotTests.swift`
- Create (stub, empty): `Tests/XS2AiOSSnapshotTests/FormLines/FlickerLineSnapshotTests.swift`
- Create (stub, empty): `Tests/XS2AiOSSnapshotTests/FormLines/ImageLineSnapshotTests.swift`
- Create (stub, empty): `Tests/XS2AiOSSnapshotTests/FormLines/TabLineSnapshotTests.swift`
- Create (stub, empty): `Tests/XS2AiOSSnapshotTests/FormLines/RestartLineSnapshotTests.swift`
- Create (stub, empty): `Tests/XS2AiOSSnapshotTests/FormLines/RedirectLineSnapshotTests.swift`

**Interfaces:**
- Produces: `XS2AiOSSnapshotTests` Xcode target + scheme; consumed by all Tasks 5–11

- [ ] **Step 1: Create stub Swift source files** (required before adding to xcodeproj)

```bash
mkdir -p Tests/XS2AiOSSnapshotTests/FormLines

# Create stub files (content added in later tasks)
files=(
  "Tests/XS2AiOSSnapshotTests/SnapshotTestCase.swift"
  "Tests/XS2AiOSSnapshotTests/Themes.swift"
  "Tests/XS2AiOSSnapshotTests/FormLines/TextLineSnapshotTests.swift"
  "Tests/XS2AiOSSnapshotTests/FormLines/PasswordLineSnapshotTests.swift"
  "Tests/XS2AiOSSnapshotTests/FormLines/CheckboxLineSnapshotTests.swift"
  "Tests/XS2AiOSSnapshotTests/FormLines/RadioLineSnapshotTests.swift"
  "Tests/XS2AiOSSnapshotTests/FormLines/SelectLineSnapshotTests.swift"
  "Tests/XS2AiOSSnapshotTests/FormLines/SubmitLineSnapshotTests.swift"
  "Tests/XS2AiOSSnapshotTests/FormLines/ParagraphLineSnapshotTests.swift"
  "Tests/XS2AiOSSnapshotTests/FormLines/DescriptionLineSnapshotTests.swift"
  "Tests/XS2AiOSSnapshotTests/FormLines/CaptchaLineSnapshotTests.swift"
  "Tests/XS2AiOSSnapshotTests/FormLines/FlickerLineSnapshotTests.swift"
  "Tests/XS2AiOSSnapshotTests/FormLines/ImageLineSnapshotTests.swift"
  "Tests/XS2AiOSSnapshotTests/FormLines/TabLineSnapshotTests.swift"
  "Tests/XS2AiOSSnapshotTests/FormLines/RestartLineSnapshotTests.swift"
  "Tests/XS2AiOSSnapshotTests/FormLines/RedirectLineSnapshotTests.swift"
)

for f in "${files[@]}"; do touch "$f"; done
```

- [ ] **Step 2: Install the xcodeproj Ruby gem**

```bash
gem install xcodeproj
```

Expected: `Successfully installed xcodeproj-x.y.z`

- [ ] **Step 3: Create the Ruby setup script**

Create `scripts/add_snapshot_target.rb`:

```ruby
#!/usr/bin/env ruby
require 'xcodeproj'

project = Xcodeproj::Project.open('XS2AiOS.xcodeproj')
main_target = project.targets.find { |t| t.name == 'XS2AiOS' }

# ── Create the test target ────────────────────────────────────────────────────
test_target = project.new_target(:unit_test_bundle, 'XS2AiOSSnapshotTests', :ios, '11.0')

test_target.build_configurations.each do |config|
  config.build_settings['SWIFT_VERSION']                  = '5.0'
  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET']     = '11.0'
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER']      = 'com.fintecSystems.XS2AiOSSnapshotTests'
  config.build_settings['CODE_SIGN_STYLE']                = 'Automatic'
  config.build_settings['GENERATE_INFOPLIST_FILE']        = 'YES'
  # Unit test bundles don't need TEST_HOST / BUNDLE_LOADER
  config.build_settings.delete('TEST_HOST')
  config.build_settings.delete('BUNDLE_LOADER')
end

# ── Depend on XS2AiOS main target ────────────────────────────────────────────
test_target.add_dependency(main_target)

# ── Add swift-snapshot-testing remote package ─────────────────────────────────
pkg = project.new(Xcodeproj::Project::Object::XCRemoteSwiftPackageReference)
pkg.repositoryURL = 'https://github.com/pointfreeco/swift-snapshot-testing.git'
pkg.requirement   = { 'kind' => 'upToNextMajorVersion', 'minimumVersion' => '1.17.0' }
project.root_object.package_references << pkg

# ── Add SnapshotTesting product dependency ────────────────────────────────────
product_dep = project.new(Xcodeproj::Project::Object::XCSwiftPackageProductDependency)
product_dep.product_name = 'SnapshotTesting'
product_dep.package      = pkg
test_target.package_product_dependencies << product_dep

# Add to Frameworks build phase
bf = project.new(Xcodeproj::Project::Object::PBXBuildFile)
bf.product_ref = product_dep
test_target.frameworks_build_phase.files << bf

# ── Create file groups ────────────────────────────────────────────────────────
tests_group    = project.main_group.find_subpath('Tests') ||
                 project.main_group.new_group('Tests', 'Tests')
snapshot_group = tests_group.find_subpath('XS2AiOSSnapshotTests') ||
                 tests_group.new_group('XS2AiOSSnapshotTests', 'XS2AiOSSnapshotTests')
fl_group       = snapshot_group.find_subpath('FormLines') ||
                 snapshot_group.new_group('FormLines', 'FormLines')

root_files = %w[SnapshotTestCase.swift Themes.swift]
root_files.each do |f|
  ref = snapshot_group.new_file(f)
  test_target.add_file_references([ref])
end

form_line_files = %w[
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
]
form_line_files.each do |f|
  ref = fl_group.new_file(f)
  test_target.add_file_references([ref])
end

# ── Save and report the target UUID for the scheme ───────────────────────────
project.save
puts "Target UUID: #{test_target.uuid}"
puts 'Done!'
```

- [ ] **Step 4: Run the Ruby script**

```bash
ruby scripts/add_snapshot_target.rb
```

Expected: `Target UUID: <some_uuid>` followed by `Done!`

Note the printed UUID — you need it in Step 5.

- [ ] **Step 5: Create the Xcode scheme file**

Create `XS2AiOS.xcodeproj/xcshareddata/xcschemes/XS2AiOSSnapshotTests.xcscheme`, replacing `TARGET_UUID` with the UUID printed in Step 4:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Scheme
   LastUpgradeVersion = "1600"
   version = "1.7">
   <BuildAction
      parallelizeBuildables = "YES"
      buildImplicitDependencies = "YES">
      <BuildActionEntries>
         <BuildActionEntry
            buildForTesting = "YES"
            buildForRunning = "NO"
            buildForProfiling = "NO"
            buildForArchiving = "NO"
            buildForAnalyzing = "YES">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "TARGET_UUID"
               BuildableName = "XS2AiOSSnapshotTests.xctest"
               BlueprintName = "XS2AiOSSnapshotTests"
               ReferencedContainer = "container:XS2AiOS.xcodeproj">
            </BuildableReference>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <TestAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      shouldUseLaunchSchemeArgsEnv = "YES">
      <Testables>
         <TestableReference
            skipped = "NO">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "TARGET_UUID"
               BuildableName = "XS2AiOSSnapshotTests.xctest"
               BlueprintName = "XS2AiOSSnapshotTests"
               ReferencedContainer = "container:XS2AiOS.xcodeproj">
            </BuildableReference>
         </TestableReference>
      </Testables>
   </TestAction>
   <LaunchAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      launchStyle = "0"
      useCustomWorkingDirectory = "NO"
      ignoresPersistentStateOnLaunch = "NO"
      debugDocumentVersioning = "YES"
      debugServiceExtension = "internal"
      allowLocationSimulation = "YES">
   </LaunchAction>
   <ProfileAction
      buildConfiguration = "Release"
      shouldUseLaunchSchemeArgsEnv = "YES"
      savedToolIdentifier = ""
      useCustomWorkingDirectory = "NO"
      debugDocumentVersioning = "YES">
   </ProfileAction>
   <AnalyzeAction
      buildConfiguration = "Debug">
   </AnalyzeAction>
   <ArchiveAction
      buildConfiguration = "Release"
      revealArchiveInOrganizer = "YES">
   </ArchiveAction>
</Scheme>
```

- [ ] **Step 6: Verify the project builds with the new target**

```bash
xcodebuild build \
  -project XS2AiOS.xcodeproj \
  -scheme XS2AiOSSnapshotTests \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO 2>&1 | tail -5
```

Expected: `** BUILD SUCCEEDED **`

If the build fails with "No such module 'SnapshotTesting'", resolve the package in Xcode once (`File → Packages → Resolve Package Versions`), then retry.

- [ ] **Step 7: Delete the temporary script and commit**

```bash
rm scripts/add_snapshot_target.rb
rmdir scripts 2>/dev/null || true
git add XS2AiOS.xcodeproj/ Tests/XS2AiOSSnapshotTests/
git commit -m "chore: add XS2AiOSSnapshotTests target with swift-snapshot-testing"
```

---

### Task 3: Write Base Infrastructure (Themes + SnapshotTestCase)

**Files:**
- Modify: `Tests/XS2AiOSSnapshotTests/Themes.swift`
- Modify: `Tests/XS2AiOSSnapshotTests/SnapshotTestCase.swift`

**Interfaces:**
- Consumes: `XS2A.StyleProvider`, `XS2A.ButtonStyle`, `XS2A.AlertStyle`, `XS2A.LinkStyle`, `XS2A.Configuration`
- Produces:
  - `let snapshotThemes: [(name: String, style: XS2A.StyleProvider)]` — consumed by `SnapshotTestCase`
  - `class SnapshotTestCase: XCTestCase` with `func assertSnapshots(named:file:line:factory:)` — consumed by all form line test files

- [ ] **Step 1: Write `Themes.swift`**

Replace the contents of `Tests/XS2AiOSSnapshotTests/Themes.swift`:

```swift
import UIKit
@testable import XS2AiOS

let snapshotThemes: [(name: String, style: XS2A.StyleProvider)] = [
    ("defaultLight", XS2A.StyleProvider()),
    ("defaultDark", darkStyleProvider)
]

private let darkStyleProvider = XS2A.StyleProvider(
    tintColor: UIColor(red: 100/255, green: 160/255, blue: 175/255, alpha: 1),
    logoVariation: .white,
    backgroundColor: UIColor(red: 28/255, green: 28/255, blue: 30/255, alpha: 1),
    textColor: .white,
    errorColor: UIColor(red: 1, green: 69/255, blue: 58/255, alpha: 1),
    inputBackgroundColor: UIColor(red: 44/255, green: 44/255, blue: 46/255, alpha: 1),
    inputBorderRadius: 6,
    inputBorderColor: .clear,
    inputBorderWidth: 0,
    inputBorderWidthActive: 2,
    inputTextColor: .white,
    placeholderColor: UIColor(red: 142/255, green: 142/255, blue: 147/255, alpha: 1),
    buttonBorderRadius: 6,
    submitButtonStyle: XS2A.ButtonStyle(
        textColor: .white,
        backgroundColor: UIColor(red: 100/255, green: 160/255, blue: 175/255, alpha: 1)
    ),
    backButtonStyle: XS2A.ButtonStyle(
        textColor: .white,
        backgroundColor: UIColor(red: 58/255, green: 58/255, blue: 60/255, alpha: 1)
    ),
    abortButtonStyle: XS2A.ButtonStyle(
        textColor: .white,
        backgroundColor: UIColor(red: 58/255, green: 58/255, blue: 60/255, alpha: 1)
    ),
    restartButtonStyle: XS2A.ButtonStyle(
        textColor: .white,
        backgroundColor: UIColor(red: 58/255, green: 58/255, blue: 60/255, alpha: 1)
    ),
    alertBorderRadius: 6,
    errorStyle: XS2A.AlertStyle(
        textColor: .white,
        backgroundColor: UIColor(red: 1, green: 69/255, blue: 58/255, alpha: 1)
    ),
    warningStyle: XS2A.AlertStyle(
        textColor: .black,
        backgroundColor: UIColor(red: 1, green: 214/255, blue: 10/255, alpha: 1)
    ),
    infoStyle: XS2A.AlertStyle(
        textColor: .white,
        backgroundColor: UIColor(red: 10/255, green: 132/255, blue: 1, alpha: 1)
    )
)
```

- [ ] **Step 2: Write `SnapshotTestCase.swift`**

Replace the contents of `Tests/XS2AiOSSnapshotTests/SnapshotTestCase.swift`:

```swift
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
```

- [ ] **Step 3: Verify it compiles**

```bash
xcodebuild build \
  -project XS2AiOS.xcodeproj \
  -scheme XS2AiOSSnapshotTests \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO 2>&1 | tail -3
```

Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 4: Commit**

```bash
git add Tests/XS2AiOSSnapshotTests/Themes.swift \
        Tests/XS2AiOSSnapshotTests/SnapshotTestCase.swift
git commit -m "feat: add SnapshotTestCase base class and theme definitions"
```

---

### Task 4: Write Input Field Tests (TextLine, PasswordLine)

**Files:**
- Modify: `Tests/XS2AiOSSnapshotTests/FormLines/TextLineSnapshotTests.swift`
- Modify: `Tests/XS2AiOSSnapshotTests/FormLines/PasswordLineSnapshotTests.swift`

**Interfaces:**
- Consumes: `SnapshotTestCase.assertSnapshots(named:factory:)`, `TextLine.init(name:label:disabled:invalid:autocompleteAction:value:placeholder:index:isLoginCredential:isRequired:errorMessage:)`, `PasswordLine.init(name:label:disabled:placeholder:invalid:index:isLoginCredential:isRequired:errorMessage:)`

- [ ] **Step 1: Write `TextLineSnapshotTests.swift`**

```swift
import XCTest
@testable import XS2AiOS

final class TextLineSnapshotTests: SnapshotTestCase {

    func test_default() {
        assertSnapshots(named: "TextLine_default") {
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

    func test_required() {
        assertSnapshots(named: "TextLine_required") {
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
                isRequired: true,
                errorMessage: nil
            )
        }
    }

    func test_invalid() {
        assertSnapshots(named: "TextLine_invalid") {
            TextLine(
                name: "account",
                label: "Account Number",
                disabled: false,
                invalid: true,
                autocompleteAction: nil,
                value: "bad-value",
                placeholder: "Enter account number",
                index: 0,
                isLoginCredential: false,
                isRequired: false,
                errorMessage: "This field contains an error."
            )
        }
    }

    func test_disabled() {
        assertSnapshots(named: "TextLine_disabled") {
            TextLine(
                name: "account",
                label: "Account Number",
                disabled: true,
                invalid: false,
                autocompleteAction: nil,
                value: "pre-filled",
                placeholder: "Enter account number",
                index: 0,
                isLoginCredential: false,
                isRequired: false,
                errorMessage: nil
            )
        }
    }
}
```

- [ ] **Step 2: Write `PasswordLineSnapshotTests.swift`**

```swift
import XCTest
@testable import XS2AiOS

final class PasswordLineSnapshotTests: SnapshotTestCase {

    func test_default() {
        assertSnapshots(named: "PasswordLine_default") {
            PasswordLine(
                name: "password",
                label: "Password",
                disabled: false,
                placeholder: "Enter password",
                invalid: false,
                index: 0,
                isLoginCredential: true,
                isRequired: false,
                errorMessage: nil
            )
        }
    }

    func test_required() {
        assertSnapshots(named: "PasswordLine_required") {
            PasswordLine(
                name: "password",
                label: "Password",
                disabled: false,
                placeholder: "Enter password",
                invalid: false,
                index: 0,
                isLoginCredential: true,
                isRequired: true,
                errorMessage: nil
            )
        }
    }

    func test_invalid() {
        assertSnapshots(named: "PasswordLine_invalid") {
            PasswordLine(
                name: "password",
                label: "Password",
                disabled: false,
                placeholder: "Enter password",
                invalid: true,
                index: 0,
                isLoginCredential: true,
                isRequired: false,
                errorMessage: "Password is incorrect."
            )
        }
    }
}
```

- [ ] **Step 3: Verify the test target builds**

```bash
xcodebuild build \
  -project XS2AiOS.xcodeproj \
  -scheme XS2AiOSSnapshotTests \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO 2>&1 | tail -3
```

Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 4: Commit**

```bash
git add Tests/XS2AiOSSnapshotTests/FormLines/TextLineSnapshotTests.swift \
        Tests/XS2AiOSSnapshotTests/FormLines/PasswordLineSnapshotTests.swift
git commit -m "feat: add snapshot tests for TextLine and PasswordLine"
```

---

### Task 5: Write Selection Control Tests (CheckboxLine, RadioLine, SelectLine, TabLine)

**Files:**
- Modify: `Tests/XS2AiOSSnapshotTests/FormLines/CheckboxLineSnapshotTests.swift`
- Modify: `Tests/XS2AiOSSnapshotTests/FormLines/RadioLineSnapshotTests.swift`
- Modify: `Tests/XS2AiOSSnapshotTests/FormLines/SelectLineSnapshotTests.swift`
- Modify: `Tests/XS2AiOSSnapshotTests/FormLines/TabLineSnapshotTests.swift`

**Interfaces:**
- Consumes: `SnapshotTestCase.assertSnapshots(named:factory:)`, `CheckboxLine.init(label:checked:name:disabled:isLoginCredential:invalid:isRequired:errorMessage:)`, `RadioLine.init(label:checked:name:options:)`, `SelectLine.init(options:label:selected:name:invalid:isRequired:errorMessage:)`, `TabLine.init(selected:tabs:)`

- [ ] **Step 1: Write `CheckboxLineSnapshotTests.swift`**

```swift
import XCTest
@testable import XS2AiOS

final class CheckboxLineSnapshotTests: SnapshotTestCase {

    func test_unchecked() {
        assertSnapshots(named: "CheckboxLine_unchecked") {
            CheckboxLine(
                label: "I accept the terms and conditions",
                checked: false,
                name: "terms",
                disabled: false,
                isLoginCredential: false,
                invalid: false,
                isRequired: false,
                errorMessage: nil
            )
        }
    }

    func test_checked() {
        assertSnapshots(named: "CheckboxLine_checked") {
            CheckboxLine(
                label: "I accept the terms and conditions",
                checked: true,
                name: "terms",
                disabled: false,
                isLoginCredential: false,
                invalid: false,
                isRequired: false,
                errorMessage: nil
            )
        }
    }

    func test_invalid() {
        assertSnapshots(named: "CheckboxLine_invalid") {
            CheckboxLine(
                label: "I accept the terms and conditions",
                checked: false,
                name: "terms",
                disabled: false,
                isLoginCredential: false,
                invalid: true,
                isRequired: true,
                errorMessage: "You must accept the terms."
            )
        }
    }
}
```

- [ ] **Step 2: Write `RadioLineSnapshotTests.swift`**

```swift
import XCTest
@testable import XS2AiOS

final class RadioLineSnapshotTests: SnapshotTestCase {

    func test_default() {
        assertSnapshots(named: "RadioLine_default") {
            RadioLine(
                label: "Choose your account type",
                checked: 0,
                name: "account_type",
                options: [
                    (label: "Checking Account", disabled: false),
                    (label: "Savings Account", disabled: false),
                    (label: "Business Account", disabled: true)
                ]
            )
        }
    }
}
```

- [ ] **Step 3: Write `SelectLineSnapshotTests.swift`**

```swift
import XCTest
@testable import XS2AiOS

final class SelectLineSnapshotTests: SnapshotTestCase {

    func test_empty() {
        assertSnapshots(named: "SelectLine_empty") {
            SelectLine(
                options: ["DE": "Germany", "AT": "Austria", "CH": "Switzerland"],
                label: "Country",
                selected: "",
                name: "country",
                invalid: false,
                isRequired: false,
                errorMessage: nil
            )
        }
    }

    func test_withSelection() {
        assertSnapshots(named: "SelectLine_withSelection") {
            SelectLine(
                options: ["DE": "Germany", "AT": "Austria", "CH": "Switzerland"],
                label: "Country",
                selected: "DE",
                name: "country",
                invalid: false,
                isRequired: false,
                errorMessage: nil
            )
        }
    }

    func test_invalid() {
        assertSnapshots(named: "SelectLine_invalid") {
            SelectLine(
                options: ["DE": "Germany", "AT": "Austria"],
                label: "Country",
                selected: "",
                name: "country",
                invalid: true,
                isRequired: true,
                errorMessage: "Please select a country."
            )
        }
    }
}
```

- [ ] **Step 4: Write `TabLineSnapshotTests.swift`**

```swift
import XCTest
@testable import XS2AiOS

final class TabLineSnapshotTests: SnapshotTestCase {

    func test_default() {
        assertSnapshots(named: "TabLine_default") {
            TabLine(
                selected: "iban",
                tabs: ["iban": "IBAN", "account": "Account Number"]
            )
        }
    }
}
```

- [ ] **Step 5: Verify build**

```bash
xcodebuild build \
  -project XS2AiOS.xcodeproj \
  -scheme XS2AiOSSnapshotTests \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO 2>&1 | tail -3
```

Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 6: Commit**

```bash
git add Tests/XS2AiOSSnapshotTests/FormLines/CheckboxLineSnapshotTests.swift \
        Tests/XS2AiOSSnapshotTests/FormLines/RadioLineSnapshotTests.swift \
        Tests/XS2AiOSSnapshotTests/FormLines/SelectLineSnapshotTests.swift \
        Tests/XS2AiOSSnapshotTests/FormLines/TabLineSnapshotTests.swift
git commit -m "feat: add snapshot tests for CheckboxLine, RadioLine, SelectLine, TabLine"
```

---

### Task 6: Write Button Tests (SubmitLine, RestartLine, RedirectLine)

**Files:**
- Modify: `Tests/XS2AiOSSnapshotTests/FormLines/SubmitLineSnapshotTests.swift`
- Modify: `Tests/XS2AiOSSnapshotTests/FormLines/RestartLineSnapshotTests.swift`
- Modify: `Tests/XS2AiOSSnapshotTests/FormLines/RedirectLineSnapshotTests.swift`

**Interfaces:**
- Consumes: `SnapshotTestCase.assertSnapshots(named:factory:)`, `SubmitLine.init(label:actionType:)`, `RestartLine.init(label:)`, `RedirectLine.init(label:url:)`, `XS2AButtonType` enum

- [ ] **Step 1: Write `SubmitLineSnapshotTests.swift`**

```swift
import XCTest
@testable import XS2AiOS

final class SubmitLineSnapshotTests: SnapshotTestCase {

    func test_submit() {
        assertSnapshots(named: "SubmitLine_submit") {
            SubmitLine(label: "Continue", actionType: .submit)
        }
    }

    func test_back() {
        assertSnapshots(named: "SubmitLine_back") {
            SubmitLine(label: "Back", actionType: .back)
        }
    }

    func test_abort() {
        assertSnapshots(named: "SubmitLine_abort") {
            SubmitLine(label: "Cancel", actionType: .abort)
        }
    }
}
```

- [ ] **Step 2: Write `RestartLineSnapshotTests.swift`**

```swift
import XCTest
@testable import XS2AiOS

final class RestartLineSnapshotTests: SnapshotTestCase {

    func test_default() {
        assertSnapshots(named: "RestartLine_default") {
            RestartLine(label: "Restart")
        }
    }
}
```

- [ ] **Step 3: Write `RedirectLineSnapshotTests.swift`**

```swift
import XCTest
@testable import XS2AiOS

final class RedirectLineSnapshotTests: SnapshotTestCase {

    func test_default() {
        assertSnapshots(named: "RedirectLine_default") {
            RedirectLine(label: "Continue in browser", url: "https://example.com")
        }
    }
}
```

- [ ] **Step 4: Verify build**

```bash
xcodebuild build \
  -project XS2AiOS.xcodeproj \
  -scheme XS2AiOSSnapshotTests \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO 2>&1 | tail -3
```

Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 5: Commit**

```bash
git add Tests/XS2AiOSSnapshotTests/FormLines/SubmitLineSnapshotTests.swift \
        Tests/XS2AiOSSnapshotTests/FormLines/RestartLineSnapshotTests.swift \
        Tests/XS2AiOSSnapshotTests/FormLines/RedirectLineSnapshotTests.swift
git commit -m "feat: add snapshot tests for SubmitLine, RestartLine, RedirectLine"
```

---

### Task 7: Write Display Component Tests (ParagraphLine, DescriptionLine)

**Files:**
- Modify: `Tests/XS2AiOSSnapshotTests/FormLines/ParagraphLineSnapshotTests.swift`
- Modify: `Tests/XS2AiOSSnapshotTests/FormLines/DescriptionLineSnapshotTests.swift`

**Interfaces:**
- Consumes: `SnapshotTestCase.assertSnapshots(named:factory:)`, `ParagraphLine.init(title:text:severity:)`, `Severity` enum (`.none`, `.info`, `.warning`, `.error`), `DescriptionLine.init(text:)`

- [ ] **Step 1: Write `ParagraphLineSnapshotTests.swift`**

```swift
import XCTest
@testable import XS2AiOS

final class ParagraphLineSnapshotTests: SnapshotTestCase {

    func test_none() {
        assertSnapshots(named: "ParagraphLine_none") {
            ParagraphLine(
                title: "Information",
                text: "Please log in using your online banking credentials.",
                severity: .none
            )
        }
    }

    func test_info() {
        assertSnapshots(named: "ParagraphLine_info") {
            ParagraphLine(
                title: "Note",
                text: "Your session will expire in 10 minutes.",
                severity: .info
            )
        }
    }

    func test_warning() {
        assertSnapshots(named: "ParagraphLine_warning") {
            ParagraphLine(
                title: "Warning",
                text: "Entering incorrect credentials multiple times may lock your account.",
                severity: .warning
            )
        }
    }

    func test_error() {
        assertSnapshots(named: "ParagraphLine_error") {
            ParagraphLine(
                title: "Error",
                text: "Your session has expired. Please start over.",
                severity: .error
            )
        }
    }
}
```

- [ ] **Step 2: Write `DescriptionLineSnapshotTests.swift`**

```swift
import XCTest
@testable import XS2AiOS

final class DescriptionLineSnapshotTests: SnapshotTestCase {

    func test_default() {
        assertSnapshots(named: "DescriptionLine_default") {
            DescriptionLine(
                text: "Enter your IBAN to connect your bank account. Your data is transmitted securely."
            )
        }
    }
}
```

- [ ] **Step 3: Verify build**

```bash
xcodebuild build \
  -project XS2AiOS.xcodeproj \
  -scheme XS2AiOSSnapshotTests \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO 2>&1 | tail -3
```

Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 4: Commit**

```bash
git add Tests/XS2AiOSSnapshotTests/FormLines/ParagraphLineSnapshotTests.swift \
        Tests/XS2AiOSSnapshotTests/FormLines/DescriptionLineSnapshotTests.swift
git commit -m "feat: add snapshot tests for ParagraphLine and DescriptionLine"
```

---

### Task 8: Write Media Component Tests (CaptchaLine, ImageLine)

**Files:**
- Modify: `Tests/XS2AiOSSnapshotTests/FormLines/CaptchaLineSnapshotTests.swift`
- Modify: `Tests/XS2AiOSSnapshotTests/FormLines/ImageLineSnapshotTests.swift`

**Interfaces:**
- Consumes: `SnapshotTestCase.assertSnapshots(named:factory:)`, `CaptchaLine.init(name:label:imageData:placeholder:invalid:index:isRequired:errorMessage:)`, `ImageLine.init(data:description:)`

Note: Both components accept a base64-encoded PNG string. A small test image is defined as a constant below.

- [ ] **Step 1: Write `CaptchaLineSnapshotTests.swift`**

```swift
import XCTest
@testable import XS2AiOS

// A 100×30 light-grey PNG encoded as base64 — used as a deterministic test image.
private let testCaptchaBase64 = "iVBORw0KGgoAAAANSUhEUgAAAGQAAAAeCAYAAADaW7vzAAAALklEQVR42u3BMQEAAADCoPVP7WsIoAAAAAAAAAAAAAAAAAAAAAAAAAAAeAMBxAAB4QgHdwAAAABJRU5ErkJggg=="

final class CaptchaLineSnapshotTests: SnapshotTestCase {

    func test_default() {
        assertSnapshots(named: "CaptchaLine_default") {
            CaptchaLine(
                name: "captcha",
                label: "Enter the characters shown",
                imageData: testCaptchaBase64,
                placeholder: "Enter captcha",
                invalid: false,
                index: 0,
                isRequired: false,
                errorMessage: nil
            )
        }
    }

    func test_invalid() {
        assertSnapshots(named: "CaptchaLine_invalid") {
            CaptchaLine(
                name: "captcha",
                label: "Enter the characters shown",
                imageData: testCaptchaBase64,
                placeholder: "Enter captcha",
                invalid: true,
                index: 0,
                isRequired: false,
                errorMessage: "The captcha you entered was incorrect."
            )
        }
    }
}
```

- [ ] **Step 2: Write `ImageLineSnapshotTests.swift`**

```swift
import XCTest
@testable import XS2AiOS

// Same small grey PNG used as a deterministic test image.
private let testImageBase64 = "iVBORw0KGgoAAAANSUhEUgAAAGQAAAAeCAYAAADaW7vzAAAALklEQVR42u3BMQEAAADCoPVP7WsIoAAAAAAAAAAAAAAAAAAAAAAAAAAAeAMBxAAB4QgHdwAAAABJRU5ErkJggg=="

final class ImageLineSnapshotTests: SnapshotTestCase {

    func test_default() {
        assertSnapshots(named: "ImageLine_default") {
            ImageLine(data: testImageBase64, description: "Bank logo")
        }
    }
}
```

- [ ] **Step 3: Verify build**

```bash
xcodebuild build \
  -project XS2AiOS.xcodeproj \
  -scheme XS2AiOSSnapshotTests \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO 2>&1 | tail -3
```

Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 4: Commit**

```bash
git add Tests/XS2AiOSSnapshotTests/FormLines/CaptchaLineSnapshotTests.swift \
        Tests/XS2AiOSSnapshotTests/FormLines/ImageLineSnapshotTests.swift
git commit -m "feat: add snapshot tests for CaptchaLine and ImageLine"
```

---

### Task 9: Write FlickerLine Test

**Files:**
- Modify: `Tests/XS2AiOSSnapshotTests/FormLines/FlickerLineSnapshotTests.swift`

**Interfaces:**
- Consumes: `SnapshotTestCase.assertSnapshots(named:factory:)`, `FlickerLine.init(name:code:label:invalid:index:placeholder:isRequired:errorMessage:)`

Note: `FlickerLine.viewDidLoad()` starts a 0.07s repeating `Timer`. The snapshot is taken synchronously before the timer fires, capturing the deterministic initial state (all flicker blocks white). The timer is invalidated when `viewDidDisappear` is called, which happens automatically when the `UIWindow` is deallocated after each assertion.

- [ ] **Step 1: Write `FlickerLineSnapshotTests.swift`**

```swift
import XCTest
@testable import XS2AiOS

final class FlickerLineSnapshotTests: SnapshotTestCase {

    func test_default() {
        assertSnapshots(named: "FlickerLine_default") {
            FlickerLine(
                name: "tan",
                code: [[1, 0, 1, 0, 1], [0, 1, 0, 1, 0]],
                label: "ChipTAN",
                invalid: false,
                index: 0,
                placeholder: "Enter TAN",
                isRequired: false,
                errorMessage: nil
            )
        }
    }
}
```

- [ ] **Step 2: Verify build**

```bash
xcodebuild build \
  -project XS2AiOS.xcodeproj \
  -scheme XS2AiOSSnapshotTests \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO 2>&1 | tail -3
```

Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 3: Commit**

```bash
git add Tests/XS2AiOSSnapshotTests/FormLines/FlickerLineSnapshotTests.swift
git commit -m "feat: add snapshot test for FlickerLine"
```

---

### Task 10: Add CI Jobs (verify + record workflows)

**Files:**
- Modify: `.github/workflows/ci.yml` (add `snapshot-tests` job)
- Create: `.github/workflows/record-screenshots.yml`

**Interfaces:**
- Consumes: `XS2AiOSSnapshotTests` scheme (from Task 2), Git LFS (from Task 1)

- [ ] **Step 1: Add `snapshot-tests` job to `ci.yml`**

Append the following job to `.github/workflows/ci.yml` (after the last existing job):

```yaml
  snapshot-tests:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v7
        with:
          lfs: true
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

- [ ] **Step 2: Create `record-screenshots.yml`**

Create `.github/workflows/record-screenshots.yml`:

```yaml
name: Record Screenshots

# Manually triggered to (re-)record golden screenshot images on a specific branch.
# Run this whenever an intentional UI change requires updating the golden baselines.
#
# Workflow:
#   1. Trigger this workflow targeting the branch that contains the UI change.
#   2. The workflow records new goldens on macos-latest (matching the verify environment).
#   3. Updated images are committed back to the branch automatically.
#   4. The snapshot-tests CI job will then pass on the next push.

on:
  workflow_dispatch:
    inputs:
      branch:
        description: 'Branch to record golden screenshots on'
        required: true
        default: 'develop'

jobs:
  record-screenshots:
    runs-on: macos-latest
    permissions:
      contents: write

    steps:
      - uses: actions/checkout@v7
        with:
          ref: ${{ github.event.inputs.branch }}
          lfs: true

      - name: Set up Git LFS
        run: git lfs install

      - name: Record golden screenshots
        run: |
          xcodebuild test \
            -project XS2AiOS.xcodeproj \
            -scheme XS2AiOSSnapshotTests \
            -destination 'platform=iOS Simulator,name=iPhone 17' \
            CODE_SIGN_IDENTITY="" \
            CODE_SIGNING_REQUIRED=NO \
            CODE_SIGNING_ALLOWED=NO \
            -testenv IS_RECORDING_SNAPSHOTS=YES

      - name: Commit updated golden images
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"
          git add Tests/XS2AiOSSnapshotTests/
          if git diff --cached --quiet; then
            echo "No screenshot changes to commit."
          else
            git commit -m "chore: update screenshot golden images [skip ci]"
            git push origin ${{ github.event.inputs.branch }}
          fi
```

- [ ] **Step 3: Verify CI YAML is valid**

```bash
python3 -c "import yaml; yaml.safe_load(open('.github/workflows/ci.yml'))" && echo "ci.yml OK"
python3 -c "import yaml; yaml.safe_load(open('.github/workflows/record-screenshots.yml'))" && echo "record-screenshots.yml OK"
```

Expected: Both print `OK`.

- [ ] **Step 4: Commit**

```bash
git add .github/workflows/ci.yml \
        .github/workflows/record-screenshots.yml
git commit -m "ci: add snapshot-tests verify job and record-screenshots workflow"
```

---

### Task 11: Generate Initial Golden Images

This task generates the first set of golden PNG files by triggering the `record-screenshots.yml` workflow and verifying that the `snapshot-tests` CI job subsequently passes.

**Prerequisite:** All previous tasks committed and pushed to the target branch.

- [ ] **Step 1: Push the branch**

```bash
git push origin <your-branch-name>
```

- [ ] **Step 2: Trigger the record workflow via GitHub CLI**

```bash
gh workflow run record-screenshots.yml \
  --field branch=<your-branch-name>
```

Expected: `Created workflow_dispatch event for record-screenshots.yml at <your-branch-name>`

- [ ] **Step 3: Monitor the workflow**

```bash
gh run list --workflow=record-screenshots.yml --limit=1
```

Wait for status `completed` with conclusion `success`. This takes ~10–15 minutes (simulator boot + xcodebuild).

- [ ] **Step 4: Pull the auto-committed golden images**

```bash
git pull origin <your-branch-name>
```

Expected: `Tests/XS2AiOSSnapshotTests/` now contains `__Snapshots__/` subdirectories with PNG files tracked by LFS.

- [ ] **Step 5: Verify LFS tracks the images**

```bash
git lfs ls-files | head -10
```

Expected: Lines like:
```
abc123def456 * Tests/XS2AiOSSnapshotTests/FormLines/__Snapshots__/TextLineSnapshotTests/TextLine_default_defaultLight.png
```

- [ ] **Step 6: Confirm the snapshot-tests CI job passes on this branch**

```bash
gh run list --workflow=ci.yml --limit=3
```

Look for a run on your branch with `snapshot-tests` job passing (green). If it shows `failed`, check `gh run view <run-id> --log-failed` for details.
