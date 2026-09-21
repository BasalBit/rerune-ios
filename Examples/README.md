# ReRune examples

Both example apps present the reviewed reading experience with native screens. Their display name and header wordmark are ReRune, and they use the existing ReRune app icons. Open `ReRuneExamples.xcworkspace` and choose `ReRuneSwiftUIExample` or `ReRuneUIKitExample`. The projects reference the local `ReRune` package and retain iOS 15 as their minimum. Chapter remains the internal name for the shared implementation and design reference.

## Content and configuration

Set `RERUNE_OTA_PUBLISH_ID` in each app's `Config/Example.xcconfig` to your OTA publish ID. Set `RERUNE_VARIANT_SLUG` to a published variant slug such as `vip`. `ChapterSDK.configure()` passes a Boolean directly to `reRuneSetup`; change that Boolean to choose the launch mode. Both settings screens include a Draft preview toggle that passes its Boolean directly to `reRuneSetStagingMode`, reads the active value from `reRuneIsStagingModeEnabled`, immediately resynchronizes, and shows the refresh outcome. The runtime selection is not persisted, so the setup Boolean applies again on the next launch. These local configuration files are preserved during SDK publication. Both apps use the package at the repository root: SDK source in the development repository and the published binary in the public repository.

Shared code and resources live under `Chapter/`. Each app owns a separate observable reading store. Opening a story does not advance it. Finishing its two chapters produces 0, 50, and 100 percent; Read again resets only that story. Bookmarks, the active tab, genre filter, and reading progress last for the app session. Locale and edition selections retain the existing persisted preferences.

Maintain translations directly in `Chapter/Resources/Chapter.bundle/<locale>.lproj/Localizable.strings` and `Localizable.stringsdict`. Plain keys and formatting accessors live in `Chapter/Sources/ChapterStrings.swift`. Keep placeholder positions and argument types aligned with those accessors. No generation step or Python tooling is required.

The `Chapter.bundle` fallback contains English, German, Spanish, French, Italian, Portuguese, and Albanian. Typed accessors resolve through `Bundle.main.localizedString`, which the SDK intercepts, with the selected bundled locale as the default value. Plain keys use `ChapterKey`; placeholder calls use `story_by(author:)`, `chapter_progress(current:total:)`, `publish_date(publish_date:)`, and `plural_sample(count:)`. An SDK revision or locale change updates visible strings without replacing reading state.

Both UIs draw story covers through the shared Core Graphics implementation. Bundled resources contain native localizations, Instrument Sans and Lora fonts, and their licenses. Font registration uses `UIAppFonts`; startup checks fail explicitly if a font is missing. Each target compiles its existing app icon catalog.

The reviewed running examples and their current source are the visual reference.
Keep only runtime assets: app icons, fonts/licenses, and localization resources.
Design reference images, golden screenshots, image-export tests, publication
captures, and manually copied SDKs do not belong in the examples. Resolve ReRune
through the existing package dependency.

## Build and review

Build and run both apps through the existing Xcode workspace and schemes.
Verify visual changes in the running apps, and test live OTA behavior against
the configured service. SDK regression tests remain in the root package targets.

Manual review of the reading experience does not establish an exhaustive device
or accessibility matrix. Check the running apps on the device sizes, locales,
and text sizes relevant to your integration.
