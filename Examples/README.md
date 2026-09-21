# ReRune example apps

These standalone SwiftUI and UIKit apps consume published ReRune iOS SDK
1.2.0 from `https://github.com/BasalBit/rerune-ios.git`. Open
`ReRuneExamples.xcworkspace` and choose either app. Xcode downloads the released
XCFramework through Swift Package Manager; no SDK source checkout or local
package override is required. Both apps support iOS 15 or later.

## Content and configuration

Both `Config/Example.xcconfig` files contain the demo configuration:

```xcconfig
RERUNE_OTA_PUBLISH_ID = 03141fc5dde6e5a1f9debf99ee68bbb125dc830412fdfb85af4834d3de341b3b
RERUNE_VARIANT_SLUG = vip
```

Replace the publish ID and variant slug for your project. Setup starts in
production mode by passing `staging: false` to `reRuneSetup(...)`.

Both settings screens include a Staging mode toggle. It calls
`reRuneSetStagingMode(_:)`, rebuilds the selected mode's cached state, and
resynchronizes before completing. Its result appears in the existing refresh
panel, and `reRuneIsStagingModeEnabled` supplies the current runtime state. The
toggle is session-scoped and is not persisted, so setup starts in production
mode again after relaunching the app. Staging switches, variant changes, and
manual refreshes block one another while running.

Shared code and resources live under `Chapter/`. Each app owns a separate observable reading store. Opening a story does not advance it. Finishing its two chapters produces 0, 50, and 100 percent; Read again resets only that story. Bookmarks, the active tab, genre filter, and reading progress last for the app session. Locale and edition selections retain the existing persisted preferences.

Maintain translations directly in `Chapter/Resources/Chapter.bundle/<locale>.lproj/Localizable.strings` and `Localizable.stringsdict`. Plain keys and formatting accessors live in `Chapter/Sources/ChapterStrings.swift`. Keep placeholder positions and argument types aligned with those accessors. No generation step or Python tooling is required.

The `Chapter.bundle` fallback contains English, German, Spanish, French, Italian, Portuguese, and Albanian. Typed accessors resolve through `Bundle.main.localizedString`, which the SDK intercepts, with the selected bundled locale as the default value. Plain keys use `ChapterKey`; placeholder calls use `story_by(author:)`, `chapter_progress(current:total:)`, `publish_date(publish_date:)`, and `plural_sample(count:)`. An SDK revision or locale change updates visible strings without replacing reading state.

Both UIs draw story covers through the shared Core Graphics implementation. Bundled resources contain native localizations, Instrument Sans and Lora fonts, and their licenses. Font registration uses `UIAppFonts`; startup checks fail explicitly if a font is missing. Each target compiles its existing app icon catalog.

The reviewed running examples and their current source are the visual reference.
Keep only runtime assets: app icons, fonts and licenses, and localization
resources. Resolve ReRune through the existing published package dependency.

## Build and review

Build and run both apps through the existing Xcode workspace and schemes. You
can also build either scheme from this directory:

```sh
xcodebuild -workspace ReRuneExamples.xcworkspace \
  -scheme ReRuneSwiftUIExample -configuration Debug \
  -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
```

Replace the scheme with `ReRuneUIKitExample` for UIKit. Verify live OTA and
staging behavior against the configured service.

Manual review of the reading experience does not establish an exhaustive device
or accessibility matrix. Check the running apps on the device sizes, locales,
and text sizes relevant to your integration.
