# ReRune Examples

Open `Examples/ReRuneExamples.xcworkspace` to access both iOS example apps from one place.

- `ReRuneUIKitExample`: themed UIKit welcome/story flow with a persisted runtime locale picker and manual rebinding from `reRuneRevisionPublisher`
- `ReRuneSwiftUIExample`: themed SwiftUI welcome/story flow with a persisted runtime locale picker and screen-level `.reRuneObserveRevision()`

Both example Xcode projects reference the local package at `../..`, so they build against the source in this repository rather than a published package.

Both examples use the shared demo OTA publish id in their local `Config/Example.xcconfig` files and target iOS 15+.
Set `RERUNE_VARIANT_SLUG` in the same file to a published Variant slug. Both
example configurations default to `vip`.
The picker lists `reRuneAvailableLocales`, calls `reRuneSetLocale(_:)`, and demonstrates dashboard-only languages without bundled language resources.
The welcome screen toggle calls `reRuneSetVariant` with persistence and switches
all visible lookups between Main and the configured Variant. The selection and
toggle position survive app relaunches.
The top of the welcome hero image overlays the formatted `publish_date` value
with the fixed date `14.07.2026` and no opaque background.
Both story screens also demonstrate an OTA string placeholder and the `ammount_of_keys` plural through native `String.localizedStringWithFormat(...)`, with bundled `.stringsdict` fallback content.
