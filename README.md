# rerune-ios

Public Swift Package Manager repository for the ReRune iOS SDK.

## Install

Add this package dependency in Xcode:

```text
https://github.com/BasalBit/rerune-ios.git
```

Then import:

```swift
import ReRune
```

## Requirements

- iOS 15+

## Public API

- `reRuneSetup(...)`
- `reRuneCheckForUpdates()`
- `reRuneRevision`
- `reRuneRevisionPublisher`
- `reRuneString(...)`
- `View.reRuneObserveRevision()`

## Example Apps

Open `Examples/ReRuneExamples.xcworkspace` to try both demo apps:

- `ReRuneUIKitExample`
- `ReRuneSwiftUIExample`

Both examples use the same demo OTA publish id and show the currently released binary package layout.
