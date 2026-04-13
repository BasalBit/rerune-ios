# ReRune SwiftUI Example

This sample demonstrates the published `ReRune` Swift package using a themed SwiftUI welcome/story flow.

## Configure

1. `Config/Example.xcconfig` is already preconfigured with the shared demo `RERUNE_OTA_PUBLISH_ID` used by the Android examples.
2. If you need to override it locally, copy `Config/Example.xcconfig` to `Config/Local.xcconfig`.
3. In Xcode, assign `Local.xcconfig` to the app target build configuration.
4. The Xcode project already points to `https://github.com/BasalBit/rerune-ios.git` and is pinned to `0.4.0`.

## Run

- Open `../ReRuneExamples.xcworkspace`.
- Select scheme `ReRuneSwiftUIExample`.
- Run on an iOS 15+ simulator or device.

## Behavior

- App initializes the SDK in `App.init` with the shared demo publish id.
- SwiftUI screens use `NSLocalizedString(...)` for OTA-managed strings and attach `.reRuneObserveRevision()` at the screen level so refresh only redraws visible content.
- The welcome screen includes pull-to-refresh, status card state, and navigation into the story screen.
- The story screen includes a manual refresh button to exercise OTA update checks from SwiftUI.
