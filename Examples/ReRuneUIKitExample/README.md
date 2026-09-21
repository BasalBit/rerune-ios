# ReRune UIKit example

The ReRune reading example implemented in UIKit. Select `ReRuneUIKitExample` in `../ReRuneExamples.xcworkspace` to run it with Xcode on iOS 15 or later.

UIKit owns every screen and control. Native controllers subscribe to the shared store and update existing labels, menus, progress views, and story cards. Each tab keeps its own scroll view. The reader keeps its chapter and bookmark through locale and OTA updates. No screen uses a SwiftUI hosting controller.

Configure your OTA publish ID and variant slug in `Config/Example.xcconfig`. `ChapterSDK.configure()` passes a Boolean directly to `reRuneSetup`; change that Boolean to choose the launch mode. The settings state reads the active value from `reRuneIsStagingModeEnabled`. The SDK package dependency, bundle identifier, and signing settings are preserved. The app registers shared resources from `../Chapter/`, displays the name ReRune, and keeps the existing ReRune app icon.

Library, Discover, and Saved lead to three stories with two chapters each. Settings includes Main and the configured edition, a draft preview toggle that switches SDK staging mode at runtime and resynchronizes, native date and plural examples, refresh results, and the session storage explanation. Refresh distinguishes updated, unchanged, and failed outcomes and blocks repeated requests while busy.

See the [shared example guide](../README.md) for localization ownership, build commands, persisted preferences, and verification limits.
