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

## Supported string lookups

ReRune 0.3.0 intercepts native Foundation localization lookups for the default `Localizable.strings` table in `Bundle.main`.

- `NSLocalizedString("key", comment: "")`
- `Bundle.main.localizedString(forKey: "key", value: nil, table: nil)`

These are the consumer-facing string lookup paths currently supported for OTA updates.

## UIKit quick start

```swift
import ReRune

reRuneSetup(otaPublishId: "replace-with-ota-publish-id")

titleLabel.text = NSLocalizedString("title", comment: "")
subtitleLabel.text = Bundle.main.localizedString(forKey: "subtitle", value: nil, table: nil)

reRuneRevisionPublisher
    .dropFirst()
    .sink { [weak self] _ in self?.rebindStrings() }
    .store(in: &cancellables)
```

## SwiftUI quick start

```swift
import SwiftUI
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

```swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text(NSLocalizedString("title", comment: ""))
            Text(Bundle.main.localizedString(forKey: "subtitle", value: nil, table: nil))
        }
    }
}
```

## Notes

- SDK installs a targeted `Bundle.main` localization override so UIKit and Foundation code can keep using native lookup APIs.
- API auth is `otaPublishId` only.
- Manifest endpoint is fixed by SDK.
- Manifest parsing is strict: root `version`, keyed `locales`, locale `version`, optional locale `url`.
- Locale payloads must be Apple `Localizable.strings` text.
- `reRuneRevisionPublisher` is the change notification stream for visible UI refreshes; the emitted value is the latest applied manifest revision and may repeat when OTA payloads change under the same manifest revision.
- Native OTA override support in phase 1 is limited to `Bundle.main` and the default `Localizable.strings` table.
- SwiftUI `Text("key")`, `LocalizedStringKey`, and `LocalizedStringResource` are not supported for OTA interception in phase 1; use `NSLocalizedString(...)` inside SwiftUI views instead.
- Periodic refresh policy uses Android-style split fields: `periodicIntervalInHours` + `periodicIntervalInDays`.

## Example apps

Open `Examples/ReRuneExamples.xcworkspace` to try both demo apps:

- `ReRuneUIKitExample`
- `ReRuneSwiftUIExample`

Both examples use the same demo OTA publish id.

They mirror the welcome/story demo flows kept in the source repo examples while consuming the published `0.3.0` package instead of the local workspace package.

The examples intentionally demonstrate both supported lookup styles: `NSLocalizedString(...)` and `Bundle.main.localizedString(...)`.
