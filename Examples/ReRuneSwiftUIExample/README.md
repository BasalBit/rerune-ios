# ReRune SwiftUI example

Open `ReRuneSwiftUIExample.xcodeproj`, or select `ReRuneSwiftUIExample`
in `../ReRuneExamples.xcworkspace`, and run on an iOS simulator. Xcode fetches
published SDK 1.1.1 from `https://github.com/BasalBit/rerune-ios.git` through
Swift Package Manager. No local SDK checkout is used.

SwiftUI owns the library, reader, controls, and settings sheet. The three tab
scroll views stay mounted to retain their independent scroll positions.
The app supports iOS 15 and retains its ReRune name, icon, and bundle identifier.

Keep `../Shared/` with this project: it supplies the example models, strings,
fonts, and cover drawing. The full `Examples/` folder can be copied out of the
repository and built independently, without Python or the root package manifest.

See the [shared guide](../README.md) for configuration, bundled translations,
and testing OTA updates.
