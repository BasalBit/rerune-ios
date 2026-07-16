# ReRune SwiftUI Example

This sample demonstrates the local `ReRune` package from this repository using a themed SwiftUI welcome/story flow.

## Configure

1. `Config/Example.xcconfig` is already preconfigured with the shared demo `RERUNE_OTA_PUBLISH_ID`.
2. If you need to override it locally, copy `Config/Example.xcconfig` to `Config/Local.xcconfig`.
3. In Xcode, assign `Local.xcconfig` to the app target build configuration.
4. The Xcode project already points to the local package path `../..`, so no SPM URL setup is required in this repo.

## Run

- Open `../ReRuneExamples.xcworkspace`.
- Select scheme `ReRuneSwiftUIExample`.
- Run on an iOS 15+ simulator or device.

## Behavior

- App initializes the SDK in `App.init` with the shared demo publish id.
- App restores the previously selected demo language from `UserDefaults` and applies it with `reRuneSetLocale(_:)`.
- SwiftUI screens use `NSLocalizedString(...)` for OTA-managed strings and attach `.reRuneObserveRevision()` at the screen level so refresh only redraws visible content.
- The welcome screen includes pull-to-refresh, status card state, a picker backed by `reRuneAvailableLocales`, and navigation into the story screen.
- Selecting a locale updates SwiftUI local state immediately, persists the locale, and calls `reRuneSetLocale(_:)` so dashboard-only languages can render without opening iOS Settings.
- The story screen shows the formatted publish date, count-1/count-2 `ammount_of_keys` plural results, and a manual refresh button.
- The plural example uses `String.localizedStringWithFormat(NSLocalizedString(...), count)` and falls back to bundled `Localizable.stringsdict` content when OTA has no valid plural.
