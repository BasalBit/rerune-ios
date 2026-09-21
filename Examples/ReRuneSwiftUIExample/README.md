# ReRune SwiftUI example

The ReRune reading example implemented in SwiftUI. Select `ReRuneSwiftUIExample` in `../ReRuneExamples.xcworkspace` to run it with Xcode on iOS 15 or later.

SwiftUI owns the library pages, reader, controls, and settings sheet. An observed shared store subscribes to SDK revisions and locale metadata. The three tab scroll views stay mounted to retain independent scroll positions.

Configure your OTA publish ID and variant slug in `Config/Example.xcconfig`. `ChapterSDK.configure()` passes a Boolean directly to `reRuneSetup`; change that Boolean to choose the launch mode. The settings state reads the active value from `reRuneIsStagingModeEnabled`. The SDK package dependency, bundle identifier, and signing settings are preserved. The app registers shared resources from `../Chapter/`, displays the name ReRune, and keeps the existing ReRune app icon.

Library, Discover, and Saved lead to three stories with two chapters each. Settings includes Main and the configured edition, a draft preview toggle that switches SDK staging mode at runtime and resynchronizes, native date and plural examples, refresh results, and the session storage explanation. Refresh distinguishes updated, unchanged, and failed outcomes and blocks repeated requests while busy.

See the [shared example guide](../README.md) for localization ownership, build commands, persisted preferences, and verification limits.
