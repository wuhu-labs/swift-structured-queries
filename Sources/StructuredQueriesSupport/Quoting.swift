#if canImport(FoundationEssentials)
  import FoundationEssentials
#else
  import Foundation
#endif

public enum QuoteDelimiter: String {
  case identifier = "\""
  case text = "'"
}

extension StringProtocol {
  package func quoted(_ delimiter: QuoteDelimiter = .identifier) -> String {
    let delimiter = delimiter.rawValue
    return delimiter + replacingAll(delimiter, with: delimiter + delimiter) + delimiter
  }

  // `String.replacingOccurrences(of:with:)` lives in full Foundation, not
  // FoundationEssentials. On the FoundationEssentials platforms the deployment
  // target is unbounded, so the standard library's `replacing(_:with:)` is
  // always available; Darwin keeps the Foundation call for back-deployment.
  package func replacingAll(
    _ target: some StringProtocol,
    with replacement: some StringProtocol
  ) -> String {
    #if canImport(FoundationEssentials)
      return String(self).replacing(target, with: replacement)
    #else
      return replacingOccurrences(of: String(target), with: String(replacement))
    #endif
  }
}
