# ReRune UIKit Example

This sample demonstrates the local `ReRune` package from this repository using a themed UIKit welcome/story flow.

## Configure

1. `Config/Example.xcconfig` is already preconfigured with the shared demo `RERUNE_OTA_PUBLISH_ID` used by the Android examples.
2. If you need to override it locally, copy `Config/Example.xcconfig` to `Config/Local.xcconfig`.
3. In Xcode, assign `Local.xcconfig` to the app target build configuration.
4. The Xcode project already points to the local package path `../..`, so no SPM URL setup is required in this repo.

## Run

- Open `../ReRuneExamples.xcworkspace`.
- Select scheme `ReRuneUIKitExample`.
- Run on an iOS 15+ simulator or device.

## Behavior

- App calls `reRuneSetup(...)` on launch with the shared demo publish id.
- All user-facing copy is read through native Foundation lookup APIs such as `NSLocalizedString(...)`.
- The welcome screen shows the OTA demo badge, title/subtitle, locale/last-synced status card, and a pull-to-refresh flow.
- The story screen shows the secondary content view and a manual refresh button.
- Visible UIKit controllers rebind their text when `reRuneRevisionPublisher` emits.
