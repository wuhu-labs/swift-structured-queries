# Build the library products against FoundationEssentials

## Summary

On non-Darwin platforms (Linux, Windows, WASM, Android), a bare
`import Foundation` binds the full swift-corelibs Foundation, which anchors
`CoreFoundation` and the ICU data tables through its `Calendar`/`Locale` code
paths. Clients that only need the essentials still pay for all of it.

This change gates every `import Foundation` in the library targets behind
`canImport(FoundationEssentials)` — the same pattern already used in
`Package.swift` — so that on those platforms the targets import
`FoundationEssentials` and fall back to `Foundation` only on Darwin. All five
library products build cleanly against FoundationEssentials:

- `StructuredQueries`
- `StructuredQueriesCore`
- `StructuredQueriesSQLite`
- `StructuredQueriesSQLiteCore`
- `StructuredQueriesTestSupport`

Most files only needed the import gated. A few referenced members that live in
full Foundation but not FoundationEssentials and were adjusted:

### `Date+ISO8601.swift`

The modern path already uses `Date.ISO8601FormatStyle`, which is available in
FoundationEssentials. Only the pre-iOS 15 / macOS 12 fallback reached for
`DateFormatter`, which FoundationEssentials does not provide. That fallback is a
Darwin back-deployment concern: on the FoundationEssentials platforms the
deployment target is unbounded and the format style is always available, so the
`DateFormatter` path is now compiled only when full Foundation backs the build.

### `String.replacingOccurrences(of:with:)`

`replacingOccurrences` is a full-Foundation extension. Three call sites now go
through a small `replacingAll(_:with:)` helper that uses the standard library's
`replacing(_:with:)` on the FoundationEssentials platforms (unbounded deployment
target) and keeps `replacingOccurrences` on Darwin for back-deployment.

### `Error.localizedDescription`

`localizedDescription` on `any Error` is a full-Foundation extension. The two
call sites (a diagnostic binding description and a test-support snapshot) fall
back to the error's textual description where full Foundation is unavailable.

## Exception: the private `_StructuredQueriesSQLite` target

`_StructuredQueriesSQLite` (an internal, non-product target used by the test
suite) is intentionally left on full `Foundation`. Its `DatabaseFunction` bridge
uses `NSCondition` and `DispatchQueue`, which have no FoundationEssentials
equivalent, and rewriting its threading is out of scope for an import-gating
change. Because it is not a product, it does not affect what library clients
link.

## What did not change

- Public API is unchanged. On Darwin (`canImport(FoundationEssentials) == false`)
  every file still imports the full `Foundation` umbrella, so `@_exported`
  Foundation symbols and behavior are identical.
- The `import` gating uses `public import` exactly where the original files did,
  preserving the re-exported Foundation surface on Darwin.

## Testing

- `swift test` on macOS (Swift 6.3): full suite green (388 tests, 51 suites).
- `swift build` on Linux (Swift 6.3, `swift:6.3-noble`) with the
  `MemberImportVisibility` upcoming feature enabled: the library products and
  test-support target compile cleanly against FoundationEssentials.

  (The `MemberImportVisibility` upcoming feature is what surfaces
  FoundationEssentials gaps as hard errors — without it the missing members bind
  silently against full Foundation; the package already enables it.)
