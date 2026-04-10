# ReRune Examples

Open `Examples/ReRuneExamples.xcworkspace` to access both iOS example apps from one place.

- `ReRuneUIKitExample`: themed UIKit welcome/story flow with manual rebinding from `reRuneRevisionPublisher`
- `ReRuneSwiftUIExample`: themed SwiftUI welcome/story flow with `.reRuneObserveRevision()`

Both example Xcode projects reference the published Swift package at `https://github.com/BasalBit/rerune-ios.git`, pinned to version `0.3.0`, so they behave like an external consumer integration instead of depending on the local checkout.

Both examples use the shared demo OTA publish id in their local `Config/Example.xcconfig` files and target iOS 15+.
