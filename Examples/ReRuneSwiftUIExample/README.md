# ReRune SwiftUI Example

This sample demonstrates SwiftUI integration with the single `ReRune` SDK module using the same live OTA publish id and demo string keys as the Android Compose example app.

## Configure

1. `Config/Example.xcconfig` is already preconfigured with the shared demo `RERUNE_OTA_PUBLISH_ID` used by the Android examples.
2. If you need to override it locally, copy `Config/Example.xcconfig` to `Config/Local.xcconfig`.
3. In Xcode, assign `Local.xcconfig` to the app target build configuration.

## Run

- Open `../ReRuneExamples.xcworkspace`.
- Select scheme `ReRuneSwiftUIExample`.
- Run on an iOS 15+ simulator or device.

## Behavior

- App initializes the SDK in `App.init` with the shared demo publish id, `.info` logging, and a 1-day periodic refresh interval.
- The screen uses the Android demo keys: `title`, `body`, `button`, `sample_placeholder`, and `last_redraw`.
- `.reRuneObserveRevision()` refreshes views after revision updates, and pull-to-refresh/manual button checks call `reRuneCheckForUpdates()`.
