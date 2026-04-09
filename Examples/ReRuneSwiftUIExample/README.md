# ReRune SwiftUI Example

This sample demonstrates the local `ReRune` package from this repository using a themed SwiftUI welcome/story flow.

## Configure

1. `Config/Example.xcconfig` is already preconfigured with the shared demo `RERUNE_OTA_PUBLISH_ID` used by the Android examples.
2. If you need to override it locally, copy `Config/Example.xcconfig` to `Config/Local.xcconfig`.
3. In Xcode, assign `Local.xcconfig` to the app target build configuration.
4. The Xcode project already points to the local package path `../..`, so no SPM URL setup is required in this repo.

## Run

- Open `../ReRuneExamples.xcworkspace`.
- Select scheme `ReRuneSwiftUIExample`.
- Run on an iOS 15+ simulator or device.

## Behavior

- App initializes the SDK in `App.init` with the shared demo publish id.
- SwiftUI views use `NSLocalizedString(...)` for OTA-managed strings and rely on `.reRuneObserveRevision()` to refresh the visible subtree.
- The welcome screen includes pull-to-refresh, status card state, and navigation into the story screen.
- The story screen includes a manual refresh button to exercise OTA update checks from SwiftUI.
