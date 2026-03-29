# ReRune UIKit Example

This sample demonstrates UIKit integration with the single `ReRune` SDK module using the same live OTA publish id and demo string keys as the Android Views example app.

## Configure

1. `Config/Example.xcconfig` is already preconfigured with the shared demo `RERUNE_OTA_PUBLISH_ID` used by the Android examples.
2. If you need to override it locally, copy `Config/Example.xcconfig` to `Config/Local.xcconfig`.
3. In Xcode, assign `Local.xcconfig` to the app target build configuration.

## Run

- Open `../ReRuneExamples.xcworkspace`.
- Select scheme `ReRuneUIKitExample`.
- Run on an iOS 15+ simulator or device.

## Behavior

- App calls `reRuneSetup(...)` on launch with the shared demo publish id, `.info` logging, and a 1-day periodic refresh interval.
- The screen mirrors the Android Views demo keys: `title`, `body`, `button`, `sample_placeholder`, `last_redraw`, `input_hint`, and `apply_programmatic_texts_button`.
- Pull-to-refresh, manual update checks, and programmatic title/body rebinding all exercise the iOS OTA lookup flow.
