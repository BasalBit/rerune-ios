# ReRune UIKit example

The ReRune reading example implemented in UIKit. Select `ReRuneUIKitExample` in
`../ReRuneExamples.xcworkspace` to run it with Xcode on iOS 15 or later. The
project resolves published SDK 1.2.0 directly from the public Git repository;
it does not use the package at the repository root.

UIKit owns every screen and control. Native controllers subscribe to the shared store and update existing labels, menus, progress views, and story cards. Each tab keeps its own scroll view. The reader keeps its chapter and bookmark through locale and OTA updates. No screen uses a SwiftUI hosting controller.

Configure the OTA publish ID and variant slug in `Config/Example.xcconfig`.
Setup starts with `staging: false`. Settings includes a Staging mode toggle that
switches the SDK mode at runtime, reads it through
`reRuneIsStagingModeEnabled`, resynchronizes, and reports the result in the
refresh panel. The selection is not persisted, so the next launch starts in
production mode. The app registers shared resources from `../Chapter/`,
displays the name ReRune, and keeps the existing ReRune app icon.

Library, Discover, and Saved lead to three stories with two chapters each.
Settings also includes Main and the configured edition, native date and plural
examples, refresh results, and the session storage explanation.

See the [shared example guide](../README.md) for localization ownership, build commands, persisted preferences, and verification limits.
