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

## Remote languages without an app release

ReRune can make dashboard-only languages available even when the app bundle shipped with only English resources. For example, if the app has only `en` bundled strings and the ReRune dashboard later publishes German (`de`), the SDK fetches the German manifest entry and locale payload in the background, caches it, and exposes `de` through `reRuneAvailableLocales`.

When German is the user's platform-preferred language, `NSLocalizedString(...)` calls can render the dashboard-delivered German strings after the first successful fetch. On the next launch, `reRuneSetup(...)` restores the cached manifest and German strings before the UI is shown, so the same language can render immediately without a compiled `de.lproj`.

This runtime language expansion is content-level. iOS Settings language lists, App Store language metadata, native system strings, and new string keys still require an app release. ReRune does not provide its own app-language override; runtime lookup follows the platform preferred language.

## UIKit quick start

```swift
import ReRune

reRuneSetup(otaPublishId: "replace-with-ota-publish-id")

titleLabel.text = NSLocalizedString("title", comment: "")

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
        }
    }
}
```

```swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        Text(NSLocalizedString("title", comment: ""))
            .reRuneObserveRevision()
    }
}
```

## Runtime language availability

After setup, apps can show the union of compiled bundle locales and ReRune dashboard locales:

```swift
let locales = reRuneAvailableLocales
```

`reRuneAvailableLocalesPublisher` emits when a manifest fetch changes the remote locale list. The active lookup language follows the platform preferred language exposed by Foundation. A dashboard-only locale can render when that locale is already the user's preferred language and ReRune has fetched or restored its remote strings.

In-app language pickers can present `reRuneAvailableLocales`, but iOS does not provide a public runtime API for adding a newly fetched dashboard-only locale to the system app-language picker after the app has shipped.

## Notes

- SDK installs a targeted `Bundle.main` localization override so UIKit and Foundation code can keep using native lookup APIs.
- API auth is `otaPublishId` only.
- Manifest endpoint is fixed by SDK to `platform=ios_xcstrings`.
- Manifest parsing is strict: root `version`, keyed `locales`, locale `version`, optional locale `url`.
- Locale payloads must be `.xcstrings` catalog JSON.
- Phase 1 only applies simple `Localizable` key/value entries from the catalog and skips unsupported entry types such as plurals, substitutions, and variations.
- Dashboard-only locales appear in `reRuneAvailableLocales` after a successful manifest fetch, or on startup when a cached manifest already lists them.
- Runtime lookup uses the platform preferred language. Missing OTA keys fall back to the app default remote locale before bundled strings.
- `reRuneRevisionPublisher` is the change notification stream for visible UI refreshes; the emitted value is the latest applied manifest revision and may repeat when OTA payloads change under the same manifest revision.
- Native OTA override support in phase 1 is limited to `Bundle.main` and the default `Localizable` table.
- SwiftUI `Text("key")`, `LocalizedStringKey`, and `LocalizedStringResource` are not supported for OTA interception in phase 1; use `NSLocalizedString(...)` inside SwiftUI views instead.
- Periodic refresh policy uses split fields: `periodicIntervalInHours` + `periodicIntervalInDays`.

## Example apps

Open `Examples/ReRuneExamples.xcworkspace` to try both demo apps:

- `ReRuneUIKitExample`
- `ReRuneSwiftUIExample`

Both examples use the same demo OTA publish id.

They mirror the welcome/story demo flows kept in the source repo examples while consuming the published package instead of the local workspace package.
