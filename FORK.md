# wuhu-labs fork

Branch `wuhu-foundation-essentials` is upstream `pointfreeco/swift-structured-queries` main at a834ac7 (0.39.2 plus commits to 2026-09-09) plus one commit, 583f625, which builds StructuredQueriesCore and StructuredQueriesSQLiteCore against FoundationEssentials so a Linux client does not link the Foundation umbrella. This file is the only other change and is not for upstream.

It replaces branch `fe-iso8601` (190fdfe on 009190f), whose patch also back-deployed the ISO 8601 and `replacingOccurrences` paths; upstream's iOS 16 floor removed both.

To rebase: branch from the new upstream main, cherry-pick the patch commit, gate any new `import Foundation` in those two targets, then add this file back with the new shas.
