# ReRune SwiftUI example

The ReRune reading example implemented in SwiftUI. Select
`ReRuneSwiftUIExample` in `../ReRuneExamples.xcworkspace` to run it with Xcode
on iOS 15 or later. The project resolves published SDK 1.2.0 directly from the
public Git repository; it does not use the package at the repository root.

SwiftUI owns the library pages, reader, controls, and settings sheet. An observed shared store subscribes to SDK revisions and locale metadata. The three tab scroll views stay mounted to retain independent scroll positions.

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
