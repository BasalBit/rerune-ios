# ReRune example apps

These are standalone SwiftUI and UIKit consumer apps for the published ReRune
iOS SDK. Both Xcode projects fetch `https://github.com/BasalBit/rerune-ios.git`
at version **1.1.1** through Swift Package Manager. Xcode downloads the released
XCFramework automatically; no SDK source checkout or local package is needed.

## Run

1. Install Xcode with an iOS Simulator runtime.
2. Open `ReRuneExamples.xcworkspace` and allow package resolution to finish.
3. Select `ReRuneSwiftUIExample` or `ReRuneUIKitExample`, choose a simulator,
   and run.

You can copy this entire `Examples/` folder anywhere and use the same workspace.
It does not depend on the repository's root `Package.swift`, build scripts,
Python, or another ReRune checkout. Keep `Shared/` alongside both app projects.
For a physical device, configure your development team and enable signing in
the selected app target. Both apps support iOS 15 or later and retain their
ReRune display name, icons, and bundle identifiers.

From this directory, you can also build either scheme on the command line:

```sh
xcodebuild -workspace ReRuneExamples.xcworkspace \
  -scheme ReRuneSwiftUIExample -configuration Debug \
  -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
```

Replace the scheme with `ReRuneUIKitExample` for UIKit. Both projects pin the
published release explicitly. Change their package version requirements in
Xcode to test a newer published SDK; do not add a local package override.

## Example code and resources

Each app owns its native screens. `Shared/Sources/ChapterStore.swift` shows the
public SDK integration directly: setup, locale selection, revision observation,
refresh, and Main/VIP edition selection. There is no copied SDK implementation
or test runtime adapter.

`Shared/Resources/` contains the fallback localization bundle, fonts, and font
licenses required by both targets. Sharing these files avoids duplicating them
in the repository. Story covers are drawn in code.

Library, Discover, and Saved lead to three two-chapter stories. Opening a story
does not advance it. Chapter completion gives 0, 50, and 100 percent progress;
Read again resets only that story. Bookmarks, progress, selected tab, and genre
are session state. Locale and edition choices keep the existing keys
`rerune.example.selectedLocale` and `rerune.example.isVariantSelected`.
Locale and SDK revision updates preserve the store and each tab's scroll view.

## Configuration

Both `Config/Example.xcconfig` files contain the shared demo configuration:

```xcconfig
RERUNE_OTA_PUBLISH_ID = 03141fc5dde6e5a1f9debf99ee68bbb125dc830412fdfb85af4834d3de341b3b
RERUNE_VARIANT_SLUG = vip
```

Replace the OTA publish ID to test your own project. The configured edition
slug must exist in that project. SDK logging defaults to `.info` in the example
store. Native `Bundle.main` lookups use the selected bundled locale as fallback.
Keep the main app bundle free of competing `Localizable` tables.

## Editing bundled translations

Edit the native `.strings` and `.stringsdict` files directly in
`Shared/Resources/ReRuneResources.bundle/<language>.lproj/`. English, German,
Spanish, French, Italian, Portuguese, and Albanian are included.

When adding a key, update `Shared/Sources/ChapterKeys.swift` and the bundled
translations. Preserve the format placeholders and plural definitions used by
the Swift accessors. No generation scripts or additional tooling are required.

## Testing OTA updates

[SDK 1.1.1](https://github.com/BasalBit/rerune-ios/releases/tag/1.1.1) adds
compatibility with the service's zero-based placeholder orders, addressing
the locale payload rejection observed with SDK 1.1.0.

To test your publish configuration, verify visible Main/VIP text changes,
native placeholders and plurals, and reading state during updates. A refresh
status alone does not confirm that visible text changed; bundled translations
remain available as fallback.
