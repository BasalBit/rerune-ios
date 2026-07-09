# ReRune Examples

Open `Examples/ReRuneExamples.xcworkspace` to access both iOS example apps from one place.

- `ReRuneUIKitExample`: themed UIKit welcome/story flow with a persisted runtime locale picker and manual rebinding from `reRuneRevisionPublisher`
- `ReRuneSwiftUIExample`: themed SwiftUI welcome/story flow with a persisted runtime locale picker and screen-level `.reRuneObserveRevision()`

Both example Xcode projects reference the local package at `../..`, so they build against the source in this repository rather than a published package.

Both examples use the shared demo OTA publish id in their local `Config/Example.xcconfig` files and target iOS 15+.
The picker lists `reRuneAvailableLocales`, calls `reRuneSetLocale(_:)`, and demonstrates dashboard-only languages without bundled language resources.
