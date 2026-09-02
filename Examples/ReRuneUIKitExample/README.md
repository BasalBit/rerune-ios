# ReRune UIKit Example

This sample demonstrates the local `ReRune` package from this repository using a themed UIKit welcome/story flow.

## Configure

1. `Config/Example.xcconfig` is already preconfigured with the shared demo `RERUNE_OTA_PUBLISH_ID`.
2. Set `RERUNE_VARIANT_SLUG` in that file to the published Variant you want
   to test. The example default is `vip`.
3. If you need to override either value locally, copy `Config/Example.xcconfig` to `Config/Local.xcconfig`.
4. In Xcode, assign `Local.xcconfig` to the app target build configuration.
5. The Xcode project already points to the local package path `../..`, so no SPM URL setup is required in this repo.

## Run

- Open `../ReRuneExamples.xcworkspace`.
- Select scheme `ReRuneUIKitExample`.
- Run on an iOS 15+ simulator or device.

## Behavior

- App calls `reRuneSetup(...)` on launch with the shared demo publish id.
- App restores the previously selected demo language from `UserDefaults` and applies it with `reRuneSetLocale(_:)`.
- All user-facing copy is read through native Foundation lookup APIs such as `NSLocalizedString(...)`.
- The welcome screen shows the OTA demo badge, title/subtitle, locale picker backed by `reRuneAvailableLocales`, Main or Variant toggle, last-synced status card, and a pull-to-refresh flow.
- The top of the hero image overlays the formatted `publish_date` value with
  the fixed date `14.07.2026`. The label has a transparent background.
- The Variant toggle calls `reRuneSetVariant` with persistence. Successful
  changes trigger the existing revision rebinding path and survive app relaunches.
  A failed change restores the previous toggle position and displays the error.
- Selecting a locale persists it and calls `reRuneSetLocale(_:)` so dashboard-only languages can render without opening iOS Settings.
- The story screen shows the formatted publish date, count-1/count-2 `ammount_of_keys` plural results, secondary content, and a manual refresh button.
- The plural example uses `String.localizedStringWithFormat(NSLocalizedString(...), count)` and falls back to bundled `Localizable.stringsdict` content when OTA has no valid plural.
- Visible UIKit controllers rebind their text when `reRuneRevisionPublisher` emits.
