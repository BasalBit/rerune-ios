# rerune-ios

Public Swift Package Manager repository for the ReRune iOS SDK.

## Requirements

- iOS 15+

## Install (SPM)

Add this package dependency in Xcode:

```text
https://github.com/BasalBit/rerune-ios.git
```

Then import:

```swift
import ReRune
```

## UIKit quick start

```swift
import ReRune

reRuneSetup(otaPublishId: "replace-with-ota-publish-id")

titleLabel.text = reRuneString("title")

reRuneRevisionPublisher
    .dropFirst()
    .sink { [weak self] _ in self?.rebindStrings() }
    .store(in: &cancellables)
```

## SwiftUI quick start

```swift
import ReRune

@main
struct ExampleApp: App {
    init() {
        reRuneSetup(otaPublishId: "replace-with-ota-publish-id")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .reRuneObserveRevision()
        }
    }
}
```

## Notes

- SDK is opt-in and does not swizzle or globally intercept iOS localization APIs.
- API auth is `otaPublishId` only.
- Manifest endpoint is fixed by SDK.
- Manifest parsing is strict: root `version`, keyed `locales`, locale `version`, optional locale `url`.
- Locale payloads must be Apple `.strings` text.
- `reRuneRevisionPublisher` is the change notification stream for visible UI refreshes; the emitted value is the latest applied manifest revision and may repeat when OTA payloads change under the same manifest revision.
- iOS intentionally keeps explicit lookup via `reRuneString(...)` instead of trying to mirror Android's wrapped native resource APIs.
- Periodic refresh policy uses Android-style split fields: `periodicIntervalInHours` + `periodicIntervalInDays`.

## Example apps

Open `Examples/ReRuneExamples.xcworkspace` to try both demo apps:

- `ReRuneUIKitExample`
- `ReRuneSwiftUIExample`

Both examples use the same demo OTA publish id and show the currently released binary package layout.
