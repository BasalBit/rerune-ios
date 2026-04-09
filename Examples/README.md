# ReRune Examples

Open `Examples/ReRuneExamples.xcworkspace` to access both iOS example apps from one place.

- `ReRuneUIKitExample`: themed UIKit welcome/story flow with manual rebinding from `reRuneRevisionPublisher`
- `ReRuneSwiftUIExample`: themed SwiftUI welcome/story flow with `.reRuneObserveRevision()`

Both example Xcode projects reference the local package at `../..`, so they build against the source in this repository rather than a published package.

Both examples use the shared demo OTA publish id in their local `Config/Example.xcconfig` files and target iOS 15+.
