# Changelog

## Unreleased

## 1.7.0 (2026-11-10)

### SDK consumer changes

- 1.7.0 adds, removes, and changes no public API, so upgrading from 1.6.1
  needs no source change.
- A `reRuneSetVariant(_:persist:)` call with `persist: true`, or a
  `reRuneResetVariant()` call, that is still running when a later
  `reRuneSetup` reads the saved selection of the same publish ID no longer
  saves. The call returns normally, logs
  `Discarded a variant change of a previous setup.` at the `.info` log
  level, and, as in 1.6.1, does not change the strings of the running
  session. `settings.json` keeps what that setup read, so the next launch
  no longer starts with the ended session's choice, as it could in 1.6.1.
  A save that reaches `settings.json` before that setup reads it is still
  saved, and that setup starts with it; so is a late save for another
  publish ID. When the choice should still apply, call
  `reRuneSetVariant(_:persist:)` again after the new `reRuneSetup`.
- Such a refused call also returns normally when `settings.json` exists
  but cannot be read, where 1.6.1 threw
  `ReRuneVariantError.persistenceFailed`, and the file stays as it is. A
  persisted call that is not refused still throws
  `ReRuneVariantError.persistenceFailed` when its save fails.
- On iOS 17 and later, a SwiftUI view or an Observation change handler that
  looks up strings while the first `reRuneSetup` runs on another thread now
  refreshes when that setup, or a later change, applies new strings.
  `Bundle.main` now gets ReRune's class and lookups at the start of the
  first setup, so such a lookup gets ReRune's answer, the app's bundled
  text until the saved strings are loaded. A lookup made before the first
  `reRuneSetup` call, or at the very start of that call, is still answered
  by the system and does not refresh. Call the first `reRuneSetup` before
  the UI reads strings, as the README quick start does in `App.init`; it
  no longer has to run on the main thread.
- Key value observing that another component adds on `Bundle.main` while
  the first `reRuneSetup` runs is now handled like observing added after
  `reRuneSetup`. The first setup logs no class warning for it, also when
  the component had given `Bundle.main` its own class before. Each later
  `reRuneSetup` logs that `Bundle.main` has a class
  `set by another component after reRuneSetup`, and on iOS 17 and later a
  lookup made on another thread while such a setup runs is answered by
  the system and does not refresh. 1.6.1 added its lookups to the
  observing class and logged the key value observing warning at every
  `reRuneSetup`. To avoid this, add the observing before the first
  `reRuneSetup` call, or run `reRuneSetup` on the main thread, so that
  SwiftUI views make no lookup while it runs.
- Fixed a crash in the app's `removeObserver` call. It happened when
  another component had given `Bundle.main` a class made at run time from
  its own Swift `Bundle` subclass and observed `Bundle.main` with key
  value observing when `reRuneSetup` ran. ReRune now adds its lookups to
  that observing class in place, as for other observing classes, and logs
  that the class
  `reports another class as its own (key value observing does this)`.

## 1.6.1 (2026-11-09)

### SDK consumer changes

- The string files that ReRune writes for `Text("key")` into
  `Library/Caches/ReRuneRuntimeStrings` are now named by their content and
  reused. Switching a language back to content it had before, or calling
  `reRuneSetup` again with the same content, uses the copy already on disk
  and its bundle, writes nothing, and creates no new bundle. New content
  still writes a new copy, and Foundation still keeps a bundle for every
  copy ReRune used until the app process ends.
- Once a new copy of a language is in use, ReRune removes that language's
  older copies of the running process except the previous one, which a
  lookup that decided just before the change may still read. Measured on
  macOS and the iOS 17.0, 18.6, and 26.5 simulators: 200 content changes of
  a 10,000 key language leave 3 directories of runtime string files in all
  (that language's current and previous copy and one of the main
  language), about 2.6 MB, instead of 202 directories and about 200 MB, and
  100 setups leave 2 directories (one per language) instead of 202.
  Content that comes back after its copy was removed gets a new copy. The
  files of earlier launches are still removed once a later launch writes
  its own.
- A setup that starts while the background write of the setup it replaces
  is still running no longer leaves that write's copy and bundle behind. A
  `Text` lookup whose language got new content, or was unloaded, while
  ReRune wrote its files no longer uses that copy: it shows a remote value
  that is not a plural directly, and for a plural the app's own string or
  the key, as when the files cannot be written.
- The first `Text` lookup after a content change, when it comes before
  ReRune's background write has finished, now also computes a digest of the
  language's values. Measured with release builds on macOS and the iOS
  17.0, 18.6, and 26.5 simulators at 10,000 keys: 16.6 to 19.4 ms instead
  of 10.6 to 12.1 ms within 3 ms of the change, 6.7 to 7.3 ms instead of
  0.3 ms at 8 ms, and no difference at 30 ms. At 2,000 keys it adds about
  2 ms right after the change and at most 0.08 ms at 3 to 30 ms. Switching
  back to content shown before, while its copy is still on disk, costs 3 to
  5 ms less than in 1.6.0 at 10,000 keys when the lookup comes within 3 ms
  of that change, and about 0.3 ms less at 8 and 30 ms. Removing older
  copies takes about 0.3 ms (at most 0.8 ms measured) on the thread that
  stores the new copy.
- A remote star width or precision (`%*d`, `%.*f`) of a key the app does
  not ship, checked against the value passed at the call site, is now
  served only where that value uses the argument as the same field (width
  or precision) of the same conversion, and as a left justified width only
  where the call site's is left justified. Before, any star of that value
  at the position counted. On macOS, with a star argument of 200,000, a
  remote `%-*f` that 1.6.0 served for a call site's `%.*f` kept
  `String.localizedStringWithFormat` busy for 3.0 s, where the call site's
  own value took 0.002 s or less. Such a value is now left out for its key
  with the field width warning, whose text now states the same field rule
  (with examples such as `%-*f` where the app's value has `%.*f`), and
  lookup uses the next available value. A remote value that repeats the
  call site's own star field, such as `%*1$d%*1$d` for `%2$*1$d`, is still
  served and pads once per copy (a known limitation).
- A backup restored from a layout that kept ReRune's crash loop markers at
  the root, without a readable manifest, no longer makes ReRune quarantine
  a language version that this install downloaded and parsed without
  ending. When setup finds no readable manifest, it now also removes the
  crash loop markers that other app processes left; the markers of parses
  still running in the app's process stay. A restore that also brings back
  a manifest can still quarantine the version that a restored marker names
  (a known limitation).
- On the first launch after an update from 1.5.0, a staging mode switch
  that runs while another `reRuneSetup(staging: true)` starts no longer
  deletes the saved staging languages, and a staging session whose first
  move of the saved languages failed shows their saved text when one is
  selected.
- A saved language is no longer dropped when a session could not move
  ReRune's files into the folder excluded from backup and later wrote a
  language at the old place: the next launch merges both folders, and a
  language file written there later replaces the older copy of the same
  language. A language saved or removed after its old copy could not be
  moved is no longer replaced by that old copy at the next launch, and a
  failed move of saved languages, when ReRune's other files moved, now
  logs that a later launch moves the rest.
- Saving a Variant selection with `persist: true` (also
  `reRuneResetVariant()`) no longer drops another publish ID's saved
  selection when a session that a later `reRuneSetup` replaced saves at the
  same time as the new session.
- When `settings.json` exists but cannot be read (for example without read
  permission), a persisted `reRuneSetVariant` or `reRuneResetVariant()` now
  fails with `ReRuneVariantError.persistenceFailed`, logs
  `Variant persistence failed.`, and keeps the file and the current
  Variant. 1.6.0 replaced the file with only this publish ID's selection
  and switched the Variant. A file that ReRune reads but cannot use (not
  JSON, for example) is still replaced.
- On iOS 17 and later, a SwiftUI view or an Observation change handler that
  looks up strings while a later `reRuneSetup` runs on another thread now
  refreshes when that setup, or a later change, applies new strings.
  Before, the setup removed ReRune's `Bundle.main` override until it
  finished, so such a lookup registered nothing and kept its text until
  something else refreshed it. During that time lookups now get ReRune's
  answer for the new setup, which is the app's bundled text until the
  saved strings are loaded. The first `reRuneSetup` call is not covered:
  call it on the main thread, as the quick start does, before the UI reads
  strings. A setup after another component changed the class of
  `Bundle.main`, for example by observing it with key value observing after
  `reRuneSetup`, is not covered either.

## 1.6.0 (2026-11-06)

### SDK consumer changes

#### Upgrade notes

- Keys the app does not ship: a remote value that reads arguments, for a key
  that no language of the app has and whose name has no format directive (a
  dashboard key such as `welcome_key`), is now used only when the lookup
  passes a default value with a matching format, for example
  `NSLocalizedString("welcome_key", value: "Welcome %@", comment: "")`.
  Otherwise ReRune skips that value and logs a warning, so
  `String(format: NSLocalizedString("welcome_key", comment: ""), name)` now
  shows `welcome_key` instead of the remote text. 1.5.0 served such values
  unchecked, and a value that did not match the call site crashed the app.
  To keep remote values for such keys, ship a development language value for
  them in the app, for example with `rerune pull`, or pass the format as the
  default value. Remote values without arguments are not affected.
- The format check of remote values now also covers keys whose value the app
  ships only in its development language (or `Base.lproj`). A key that no
  language of the app has but whose name contains format directives, such as
  the `%lld keys` key of `Text("\(count) keys")`, is checked against its own
  directives, and literal percent signs in its remote values are escaped. A
  locale that 1.5.0 applied can therefore now be rejected as a whole, with
  the usual warnings.
- With `checkOnStart` on (the default), ReRune now checks for updates every
  time the app returns to the foreground from the background: one manifest
  request per return, answered with `304` when nothing changed. The limit of
  one check every 15 minutes and the one minute retry wait no longer apply to
  returns, and a return while a check is running joins it. Becoming active
  without having been in the background (Control Center, a system alert, a
  permission prompt) does not check, and launch still does not repeat the
  startup check. `checkOnStart: false` still turns off both automatic checks,
  and the periodic interval and `reRuneCheckForUpdates()` work as before.
- To start in a language the user chose earlier, call `reRuneSetLocale` with
  it right before `reRuneSetup`, for example
  `reRuneSetLocale(UserDefaults.standard.string(forKey: "selectedLocale"))`.
  Behavior change: 1.5.0's `reRuneSetup` cleared a language selected before
  it, so an app that calls `reRuneSetLocale` before setup now starts in that
  language instead of the device language. ReRune does not save the
  selection, and it lasts for that first session only: every later
  `reRuneSetup` clears it, so an app that calls `reRuneSetup` again and wants
  to keep the language calls `reRuneSetLocale` with it after that setup. A
  tag that is not a locale identifier uses the device language and is
  logged. The `reRuneSetup` signatures are unchanged.
- `reRuneObserveRevision()` is deprecated on iOS 17 and later, where it has
  no effect because views that look up strings in `body` refresh
  automatically. Apps with a minimum deployment target of iOS 17 or later get
  a deprecation warning and can remove it. Apps that support iOS 15 or 16
  keep it and see no warning.

#### SwiftUI and lookups

- SwiftUI `Text("key")`, and views that take a key directly, such as
  `Button("key")`, `Label`, `Toggle`, and `navigationTitle`, now show ReRune
  values for keys that the ReRune dashboard delivers, without code changes,
  including Markdown. SwiftUI resolves these strings when it creates the
  view, so screens opened after an update show the new values; a `Text`
  already on screen may keep its previous value. Strings looked up in
  `body`, such as `Text(NSLocalizedString("key", comment: ""))`, refresh on
  screen on iOS 17 and later, or with `reRuneObserveRevision()` on iOS 15
  and 16. Inside `.environment(\.locale, ...)` with a locale other than the
  device's current locale, these views show the app's shipped strings.
- A remote value reaches a call site only when its dashboard key equals the
  key the app looks up, character for character. For keys shared with
  Android, such as `welcome_key`, use `Text("key")` for strings without
  arguments,
  `Text(String(format: NSLocalizedString("welcome_key", comment: ""), name))`
  for strings with arguments, and `String.localizedStringWithFormat` with
  `NSLocalizedString` for plurals. An interpolated `Text` looks up the key
  Swift generates from it: `Text("\(count) keys")` looks up `%lld keys`, and
  a dashboard key such as `keys_count` does not reach it.
- `Text("key")` follows the same lookup order as `NSLocalizedString`, and
  only the default `Localizable` table of the main bundle is served.
  `String(localized:)`, `LocalizedStringResource`, and
  `AttributedString(localized:)` are not served by ReRune; use
  `NSLocalizedString` for those strings. `String(localized:)` was observed to
  show ReRune values on iOS 17; do not rely on it.
- To serve `Text("key")`, ReRune writes each locale's accepted remote values
  as string files into `Library/Caches/ReRuneRuntimeStrings`: a new copy at
  each content change of a language in the lookup order and at each
  `reRuneSetup`, about 1 MB for a language of 10,000 keys, kept until a later
  launch writes its own files. Foundation keeps a bundle for every copy in
  `Bundle.allBundles` until the app process ends. When the files cannot be
  written or other code removes them, `NSLocalizedString` keeps its remote
  values, and `Text("key")` keeps them too, except that a remote plural can
  show the app's own string or the key, until new files are written. Code
  that reads `bundleURL` of every entry of `Bundle.allBundles` (a crash
  reporter, for example) keeps working.
- On iOS 18.4 and later,
  `Bundle.main.localizedString(forKey:value:table:localizations:)` returns
  ReRune values when iOS resolves the requested languages to the current
  language, the first language of ReRune's order; other requests keep the
  system's lookup of the app's shipped strings. An empty language list, or
  one with an entry that is not a string, reaches the system first, so on
  iOS 17.0 it raises exactly as it does without ReRune.
- Only `Bundle.main` itself is served, not another bundle object of the same
  class. When another component set its own class on `Bundle.main` before
  `reRuneSetup` (for example an in-app language library), ReRune now gives
  `Bundle.main` a class derived from that class instead of replacing it, so
  a cast to that class and its own lookups keep working for everything
  ReRune does not serve. When `Bundle.main`
  is observed with key value observing at setup, ReRune adds its lookups to
  the observing class instead; once the last observer is removed, ReRune
  serves no remote values until the next `reRuneSetup`. Each case logs a
  warning. `localizedString(forKey:value:table:localizations:)` is added to
  `Bundle.main` only where the system implements it, so `responds(to:)`
  answers as it does without ReRune, and arguments of an unexpected type,
  such as an `NSNull` key, reach the system unchanged.

#### Language selection and loading

- How ReRune picks the language: lookup now follows the language iOS picks
  for the app, with ReRune's values on top. iOS chooses from the app's
  bundled languages, its development language, and the languages ReRune has
  saved from the dashboard, trying every language in the phone's list in
  order (or the language selected with `reRuneSetLocale`, which is matched
  like a phone language); the dashboard's main language comes last. At each
  language, the ReRune value comes before the app's bundled string. An
  update check that saves a language that matches the phone better changes
  the language shown without a call to `reRuneSetLocale`, followed by one
  refresh through `reRuneRevisionPublisher`. Examples:
  - A Taiwan phone (`zh-Hant-TW`) in an app with `zh-TW` and `zh-Hant`
    strings uses `zh-TW`, then `zh-Hant`. Plain `zh` is never used for a
    Traditional Chinese phone; 1.5.0 could show Simplified text.
  - A phone set to French, then Italian, in an app that ships only English
    and has Italian on the dashboard now shows Italian; 1.5.0 used only the
    first language of the phone's list.
  - An `en-IN` phone in an app with `en` and `en-GB` uses `en-GB`, and a
    `pt-PT` phone in an app with `en` and `pt-BR` uses `pt-BR`. 1.5.0 showed
    `en` for these phones once it had a main language.
  - A phone whose languages the app has in no form shows the app's
    development language, as iOS does, before the main language. When the
    two differ, this changes what 1.5.0 showed (the main language).
- Languages now load on demand. `reRuneSetup` reads and parses only the
  saved languages of the lookup order on the calling thread (1.5.0 parsed
  every saved language there), so launch time and memory no longer grow with
  the number of saved languages. Update checks still download every published
  language, so switching works offline. `reRuneSetLocale` to a language that
  is not loaded reads and parses it on the calling thread before it returns,
  and unloads the languages the app no longer uses, so switching back loads
  them again. A call that races a `reRuneSetup` on another thread can return
  before the language loads. A memory warning unloads every language outside
  the one in use and its fallbacks. ReRune keeps its reference to the string
  bundle it wrote for SwiftUI `Text` of a language that left the order until
  the next `reRuneSetup`, also after a memory warning, and Foundation keeps
  every such bundle until the app process ends. When the language in use is
  unexpectedly not loaded and loading it is not quick, a lookup shows the
  app's own text and the language loads in the background, followed by one
  refresh through `reRuneRevisionPublisher`. A saved language that does not
  load leaves `reRuneAvailableLocales` and is downloaded again by the next
  update check.

#### Update checks and publishers

- `reRuneAvailableLocalesPublisher` and
  `reRuneAvailableLocaleDetailsPublisher` now send a value only when it
  differs from the last value they sent, so an update check that changes
  nothing (for example one answered with `304`) sends no event. 1.5.0 sent
  both values at every setup and after every update check that applied a
  manifest, changed or not. Every change of the language list or of a
  language name is still sent.
- A periodic interval longer than 366 days, such as `.max` used to mean
  "never", now counts as 366 days, with a logged error, instead of crashing.

#### Remote values and crash safety

- ReRune no longer crashes or hangs the app in cases that were ReRune's own
  doing, among them remote values that made `String(format:)`,
  `String.localizedStringWithFormat`, or SwiftUI `Text` read arguments the
  app never passes, deeply nested or oversized manifests and locale payloads,
  `reRuneSetup` running again while another `reRuneSetup` or an update check
  ran, duplicate cached locale files, and a shipped `.stringsdict` whose
  plural rules refer to themselves. A crash that happens without ReRune as
  well happens exactly as it does without ReRune. ReRune installs no signal
  or exception handlers.
- Remote values that would crash or hang the app when it formats them are
  now left out for their key alone, with a warning that names the key, while
  the rest of the locale applies. Examples: the `% s` in the French
  `50 % sur tout` (to keep such a value, write it with a no-break space after
  the percent sign; `50% off` is still shown), `%n`, `%P`, a star width or
  precision (`%*d`) where the app passes no field width, an argument number
  of 128 or more, `%S` where the app passes a C string for `%s`, a field
  width taken from a number the app passes for another purpose, Markdown
  that SwiftUI `Text` renders into a directive or as nothing, and Markdown
  extended attributes with more than 64 brackets and braces. A Markdown
  rendering that forms a directive the app's own value does not read rejects
  the whole locale. A remote value ReRune leaves out falls back like a
  missing value.
- A remote value that drops a lower placeholder now rejects its locale when
  the placeholder after it has another type, for example one that keeps
  `{{folder}}` (text) but drops `{{count}}` (a number); dropping a
  placeholder of the same type is still accepted. `&#37;`, `&#x25;`, and
  `&percnt;` in remote values of formatted keys are now escaped like a
  literal percent sign.
- Limits: a locale payload larger than 32 MiB, with more than 200,000
  records, nested deeper than 48 levels, or with a NUL byte is rejected like
  any other invalid payload, and a manifest larger than 4 MiB, nested deeper
  than 48 levels, or with a NUL byte fails (`.failed`). A value whose
  Markdown check would exceed 256 KiB per text or 1 MiB per locale is left
  out for its key with a warning.
- Crash loop protection: when a launch ends twice while ReRune parses or
  applies the same cached or downloaded locale payload, ReRune quarantines
  that locale version: it removes the cached copy, does not download or
  apply that version again until a new version is published or the app is
  updated, and logs an error.
- When other code empties the app's temporary directory while ReRune builds
  the formats of remote plurals there, the build now fails like any other
  failed plural build, which an update check logs as
  `Locale <tag> synchronization failed.` while it keeps that language's
  earlier values.
- An empty remote value (`""`, or a message whose parts are all empty text)
  now counts as no translation, so every lookup shows what it shows without
  that value; 1.5.0 returned the empty string. In a remote plural, a count
  whose form is empty shows the `other` form, and a plural whose every form
  is empty, or an empty value of the selected Variant, counts as no
  translation too. Whitespace is still a real value.

#### Setup and logging

- `reRuneSetup` now stops the app only for a publish ID it cannot use, and
  says why in Release builds too: an empty or blank `otaPublishId`, as
  before, and, new, an `otaPublishId` of `.` or `..`. In 1.5.0, optimized
  builds, including the released binary, stopped without a message.
- Other invalid setup values no longer stop the app. ReRune logs an error
  (from the `.error` log level, and in the system log even with
  `logLevel: .off`) and continues with a corrected value: a negative
  `periodicIntervalInHours` or `periodicIntervalInDays` counts as `0` (1.5.0
  stopped the app); a `requestTimeout` that is not a finite number of at
  least 0.001 seconds counts as 10 seconds, and one longer than 60 seconds
  as 60 seconds; an invalid variant slug passed to `reRuneSetup(variant:)` or
  `reRuneSetVariant`, or stored earlier, selects Main, and
  `reRuneSetVariant` with an invalid slug and `persist: true` saves nothing.
  A stored selection that holds no text slug now also selects Main. A valid
  slug has 1 to 64 lowercase ASCII letters, digits, `_`, or `-` and
  starts with a letter.
- `reRuneSetup` calls now run one at a time. A `reRuneSetup` called from code
  that a running `reRuneSetup` triggers on the same thread (for example an
  Observation `onChange` handler) is ignored and logged, where 1.5.0 recursed
  until the stack overflowed. Results of an earlier setup that arrive after a
  new `reRuneSetup` are discarded. Observation change handlers that a
  `reRuneSetup` on the main thread triggers now run after setup has finished
  its work, so they read the new session's values. On iOS 17 and later,
  changes made on other threads reach Observation change handlers and SwiftUI
  views in one update instead of one update per change;
  `reRuneRevisionPublisher` and the other publishers are not affected.
- Errors, warnings, and safety events are now also written to the unified
  system log under the subsystem `io.rerune.sdk` (categories `setup`,
  `runtime`, and `safety`), even with `logLevel: .off`, once per distinct
  message per process. They never contain translation values or the publish
  ID. From `.info`, the SDK log still shows the publish ID in request URLs,
  and the `errorMessage` of a failed update check can contain it, as in
  1.5.0.
- A publish ID that contains an unpaired UTF-16 surrogate no longer crashes
  on iOS 17 and 18 and no longer drops the ID from the request on iOS 15.

#### Storage and privacy

- ReRune now ships a privacy manifest (`PrivacyInfo.xcprivacy`) in the Swift
  package and in every framework slice of the XCFramework. It declares no
  tracking, no tracking domains, no collected data, and no required reason
  APIs.
- ReRune's cache in Application Support is now excluded from iCloud and
  computer backups, except the Variant selection saved with
  `reRuneSetVariant(persist: true)`, which stays in backups. The first launch
  with 1.6.0 moves the files 1.5.0 wrote, so nothing downloads again. After a
  restore, the app shows its own strings, with the saved Variant selection,
  until the next update check downloads the languages. An app that goes back
  to 1.5.0 after the move downloads its translations again.
- Saving a Variant selection with `persist: true` now keeps the other
  publish IDs' saved selections, which 1.5.0 dropped when the file held an
  entry it could not read.

## 1.5.0 (2026-10-22)

### SDK consumer changes

- A locale payload with any incompatible remote value is now rejected as a
  whole. This covers a value that reads format arguments the shipped value
  does not pass (since 1.4.0 such a value was ignored per key) and a
  `{{placeholder}}` without a matching declaration (since 0.11.0 such a value
  fell back per key). The previously applied values for that locale stay in
  use, or lookup continues with the next step of the lookup order, so the app
  never shows a partially applied update. Nothing is thrown to the
  app: ReRune logs one warning per rejected key and one warning that the
  locale was not applied, from the `.error` log level.
- A cached locale that no longer matches the app's shipped formats (for
  example after an app update) is not restored at launch and is logged the
  same way.
- A rejected locale version is not downloaded again until a new version is
  published, the variant changes, or the app is updated (marketing version or
  build number). The rejection is remembered across launches.
- Lookup order changed. Each step of the current language, from most to
  least specific, is tried OTA and then in the app's bundled strings, followed
  by the main language the same way. For `de-AT` with main language `en`: OTA
  `de-AT`, bundled `de-AT`, OTA `de`, bundled `de`, OTA `en`, bundled `en`.
  Previously the main language's OTA value won over the app's bundled text in
  the current language, and a key that only `de.lproj` contained was skipped
  for `de-AT`. The current language is the one passed to `reRuneSetLocale`,
  or the phone language when none is set.
- `reRuneSetVariant` no longer fails when one locale has an incompatible value
  for the new variant. That locale falls back and is logged, and the variant
  change applies to the other locales.

## 1.4.1 (2026-10-22)

### SDK consumer changes

- Fixed the shipped format check for apps that use String Catalogs
  (`.xcstrings`). A remote value for a key whose shipped plural sits inside a
  device variation is now checked against that plural, so a value that reads
  an integer where the app passes a decimal number is ignored instead of
  showing a wrong number, and a compatible value is no longer ignored. A
  plural without a shipped definition no longer counts as an integer
  argument.
- Fixed compatible remote values being ignored for shipped strings with
  numbered plural substitutions, such as `%1$#@files@ in %2$#@folders@`,
  which String Catalogs create for strings with several plurals.

## 1.4.0 (2026-10-22)

### SDK consumer changes

- Remote translations can no longer read format arguments that the app does
  not pass. ReRune compares each remote value with the value the app ships for
  the same key. A remote value that reads an argument the shipped value does
  not read, or reads one with a different kind (for example an object where
  the app passes an integer), is ignored, and lookup falls back through the
  main language and the bundled strings. Keys the app does not ship are not
  checked.
- When the shipped value is a format string, literal percent signs in a remote
  value are escaped, so `Save 50% today` displays unchanged when the app
  formats it. Previously such text could be read as a format directive.
- On iOS 17 and later, SwiftUI views that look up ReRune strings in their
  `body` refresh automatically when translations change. No modifier is
  needed.
- Fixed `reRuneObserveRevision()` not refreshing the views it wraps. On iOS 15
  and 16 it now rebuilds the wrapped subtree when translations change, which
  also resets that subtree's view state. On iOS 17 and later it changes
  nothing, because views refresh automatically.
- `checkOnStart` now also covers returns to the foreground: ReRune checks for
  updates when the app opens, whether iOS launches it or resumes it, at most
  once every 15 minutes after a successful check. A failed check is retried on
  the next open after one minute. `checkOnStart: false` turns off both, so a
  return to the foreground does not check either.
- The periodic interval now works across suspensions. iOS does not run the
  in-process timer while the app is suspended, so ReRune also checks on the
  next return to the foreground once the interval has passed since the last
  successful check, even with `checkOnStart: false`. The timer now waits for
  the interval since the last check of any kind, so a check started by the app
  opening or by `reRuneCheckForUpdates()` postpones the next timer check.
- `reRuneCheckForUpdates()` always starts a check, regardless of the
  intervals above, and counts as the last check for them. No public API
  changes.
- ReRune now logs a warning for every remote value it ignores, naming the
  locale, the key, and the reason (a placeholder mismatch or an incompatible
  format). Warnings appear from the `.error` log level, so
  `logLevel: .error` is enough to see when published content is not used.

## 1.3.1 (2026-10-20)

### SDK consumer changes

- Manifest and locale requests now send `User-Agent: rerune-ios/<version>`
  (`rerune-ios/1.3.1` in this release), so CDN logs show which SDK version made
  each request. It replaces the iOS default, which named the host app, its
  build, and the CFNetwork and Darwin versions. No public API changes.

## 1.3.0 (2026-10-20)

### SDK consumer changes

- The SDK now requests the manifest from
  `https://cdn.rerune.io/api/ota/<otaPublishId>/manifest.json`. The publish ID
  is trimmed and sent as one percent-encoded URL path segment, never as a
  request header. Locale requests keep using the URLs that the manifest
  returns.
- Locale files follow the CDN file layout. A first load or a changed
  `minimum_delta_base_version` requests the manifest locale URL unchanged
  (for example `.../sq/88.json`). An update from a cached version prepends
  that version and `..` to the file name (for example `.../sq/86..88.json`).
  The `version` and `target_version` query parameters are no longer sent.
- Every manifest and locale request now reaches the network. The SDK uses
  its own `URLSession` with no local HTTP cache instead of
  `URLSession.shared`. Previously the CDN's `Cache-Control: max-age=300` let
  iOS answer a manifest refresh from the app's HTTP cache for up to 5
  minutes, so newly published changes were missed until the cache expired or
  the app was reinstalled. App level `URLProtocol` classes registered
  globally no longer see SDK requests.
- `.info` and `.verbose` logs show the publish ID as part of the logged
  request URLs. The publish ID is not a secret.
- No public API changes. `reRuneSetup(otaPublishId:...)` keeps its name and
  meaning.

## 1.2.0 (2026-09-21)

### SDK consumer changes

- Added opt-in staging preview through the `staging:` argument on
  `reRuneSetup(...)`. It defaults to `false` and applies only to the current
  setup session.
- Added `reRuneSetStagingMode(_:)` for switching modes and synchronizing
  immediately after setup. Added `reRuneIsStagingModeEnabled` for reading the
  active mode. Calling the setter before setup throws
  `ReRuneStagingModeError.setupRequired`.
- Staging synchronization now applies complete locale snapshots, so draft
  additions, edits, deletions, disabled values, and never-published keys are
  reflected on the next successful sync.
- Staging and production state are isolated. A mode change restores the
  selected mode's cached content, and results from superseded update checks are
  discarded instead of crossing between modes.

## 1.1.1 (2026-09-14)

### SDK consumer changes

- Fixed locale payloads that use zero-based placeholder positions. These
  payloads previously caused the affected locale to be rejected. Existing
  positive Foundation positions retain their meaning.

## 1.1.0 (2026-09-02)

### SDK consumer changes

- Added translation variants through `ReRuneVariant`, the `variant:` argument
  on `reRuneSetup(...)`, `reRuneSetVariant(_:)`, and `reRuneResetVariant()`.
  Variant selection persists for each project, while `.main` selects the main
  translation.
- Added main-translation fallback for missing variant values. Variant strings
  continue through the existing placeholder and plural formatting behavior.
- Fixed text-only structured messages so literal percent signs remain
  unchanged.
- Added the MIT license to the downloadable XCFramework archive.

## 1.0.0 (2026-08-05)

### SDK consumer changes

- Declared the SDK contract stable with the first `1.x` release.
- No SDK runtime or public API changes from `0.13.1`.

## 0.13.1 (2026-07-29)

### SDK consumer changes

- Maintenance release with no SDK runtime or public API changes from `0.13.0`.
- The XCFramework retains the public Swift module interface required by
  consuming apps and no longer includes private symbol metadata.

## 0.13.0 (2026-07-28)

### SDK consumer changes

- Restored the MIT license for the SDK and binary package. Version `0.12.0`
  retains the proprietary license included in that release.
- No SDK runtime or public API changes from `0.12.0`.

## 0.12.0 (2026-07-28)

### SDK consumer changes

- Changed this release to BasalBit GmbH's proprietary commercial license.
  Earlier releases retain the licenses included with their tags.
- No SDK runtime or public API changes from `0.11.0`.

## 0.11.0 (2026-07-27)

### SDK consumer changes

- Breaking: replaced String Catalog payload transport with locale-scoped JSON
  records. Apps continue using native `NSLocalizedString`, `String(format:_:)`,
  and `String.localizedStringWithFormat` call sites.
- Breaking: each manifest locale now requires an absolute `url`. The previous
  `platform=ios_xcstrings` request and hardcoded locale endpoint are no longer
  used.
- Added named `{{placeholder}}` tokens and structured cardinal plurals with a
  separate control argument. A placeholder mismatch falls back only for the
  affected key instead of rejecting the full locale.
- Added untranslated records. An empty `values` array removes an earlier OTA
  override, while an empty string remains an intentional translation.
- Breaking: moved persistence to the `ReRuneGenericV1` cache namespace. Older
  platform-specific caches are not migrated and must be downloaded again.

## 0.10.0 (2026-07-24)

### SDK consumer changes

- Breaking: locale synchronization now uses stored `version` and requested
  `target_version` values instead of RFC 3339 `updated_at` cursors.
- Added automatic recovery when a locale rejects a stale manifest. The SDK
  refreshes the manifest once before reporting a terminal failure.
- Added optional locale display names through `ReRuneLocale`,
  `reRuneAvailableLocaleDetails`, and
  `reRuneAvailableLocaleDetailsPublisher`. Compiled-only locales use their
  identifier as the display-name fallback.

## 0.9.0 (2026-07-21)

### SDK consumer changes

- Breaking: replaced the previous logging levels with cumulative `off`,
  `error`, `info`, and `verbose` levels. Logging now defaults to `off`.
- Added consistently prefixed network and synchronization diagnostics.
  Sensitive request details are emitted only when `verbose` logging is
  explicitly enabled.

## 0.8.0 (2026-07-21)

### SDK consumer changes

- Added incremental per-locale String Catalog updates. Unchanged locale
  versions are skipped, while changed locales receive atomic delta merges.
- Removed cached data for locales that are no longer published in the
  manifest.
- Breaking: locale identifiers must use the
  `language[-Script][-REGION]` form, and manifest versions must be
  non-negative JSON integers.
- Breaking: cache records from earlier SDK versions are incompatible and are
  replaced by a fresh locale download.
- Cache restoration remains synchronous for immediate startup lookups, while
  startup and periodic network synchronization run without blocking
  `reRuneSetup(...)`.

## 0.7.0 (2026-07-16)

### SDK consumer changes

- Added OTA missing-key fallback through the manifest's required
  `main_language` value.
- Added dashboard-delivered cardinal plurals for direct `variations.plural`
  entries and standard String Catalog substitutions. Existing
  `NSLocalizedString(...)` and `String.localizedStringWithFormat(...)` call
  sites continue to work.
- Breaking: manifests without a valid `main_language` are rejected. Invalid
  cached manifests and their locale data are cleared during setup.
- Plural category selection follows the device formatting locale. A runtime
  locale override with different plural rules may therefore select unexpected
  categories.

## 0.6.1 (2026-07-09)

### SDK consumer changes

- Reintroduced `reRuneSetLocale(_:)` and `reRuneSelectedLocale` so in-app
  language pickers can switch immediately to dashboard-delivered locales.

## 0.6.0 (2026-07-09)

### SDK consumer changes

- Breaking: removed `reRuneSetLocale(_:)` and `reRuneSelectedLocale`. Runtime
  lookup follows the platform preferred language, then the app's default
  remote locale, then bundled strings.
- `reRuneAvailableLocales` and `reRuneAvailableLocalesPublisher` remain
  available for presenting supported languages.

## 0.5.1 (2026-07-09)

### SDK consumer changes

- Fixed the Swift Package Manager checksum so the published
  `ReRune.xcframework.zip` installs successfully.
- No SDK runtime changes from `0.5.0`.

## 0.5.0 (2026-07-08)

### SDK consumer changes

- Added `reRuneAvailableLocales` and `reRuneAvailableLocalesPublisher` so apps
  can present compiled and dashboard-delivered languages together.
- Added `reRuneSetLocale(_:)` and `reRuneSelectedLocale` for selecting a
  dashboard-only language from an in-app picker.
- OTA lookup uses the selected locale, or the system preferred locale when no
  override is active, before falling back to the app's default remote locale
  and bundled strings.

## 0.4.0 (2026-04-13)

### SDK consumer changes

- Breaking: switched OTA payloads from flat `.strings` content to String
  Catalog JSON through the `ios_xcstrings` platform. This release supports
  simple `Localizable` key and value entries only.
- `reRuneCheckForUpdates()` now continues an in-flight OTA fetch if the calling
  SwiftUI refresh task is cancelled.

## 0.3.0 (2026-04-09)

### SDK consumer changes

- Breaking: replaced explicit `reRuneString(...)` lookups with native
  `Bundle.main` interception for `Localizable.strings`. Existing
  `NSLocalizedString(...)` and `Bundle.localizedString(...)` call sites can
  receive OTA values.
- Removed the public cache-store types. `reRuneSetup(...)` restores cached OTA
  strings before returning.
- SwiftUI `Text("key")` does not use the intercepted lookup path in this
  release.

## 0.2.2 (2026-04-04)

### SDK consumer changes

- Fixed the XCFramework so it includes the Swift module metadata required for
  `import ReRune`.
- Added UIKit and SwiftUI integration quick starts to the public package.

## 0.2.1 (2026-03-30)

### SDK consumer changes

- Breaking: replaced the static `ReRune.*` namespace with top-level
  `reRune*` functions and values.
- Lowered the minimum supported iOS version from 16 to 15.

## 0.2.0 (2026-03-28)

### SDK consumer changes

- Breaking: merged `ReRuneCore` and `ReRuneSwiftUI` into a single `ReRune`
  module and package product.
- Breaking: changed OTA locale payloads to Apple `.strings` text through the
  `ios_localizable_strings` platform. Legacy JSON locale payloads are no
  longer accepted.
- Breaking: raised the minimum iOS version to 16 and split
  `ReRuneUpdatePolicy.periodicInterval` into hour and day interval fields.
- Delivered `reRuneRevisionPublisher` updates on the main thread so UIKit
  observers can refresh UI safely.
- Locale update failures preserve cached values. A cached manifest can still
  revalidate locale payloads after a `304` response.

## 0.1.0

### SDK consumer changes

- Initial Swift Package Manager release with `ReRuneCore` and
  `ReRuneSwiftUI` modules.
- Added `reRuneSetup(...)`, `reRuneCheckForUpdates()`, `reRuneRevision`, and
  `reRuneString(...)`.
- Added cache-first OTA manifest and locale updates with bundled-string
  fallback.
