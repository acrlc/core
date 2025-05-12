import Foundation
public extension StringProtocol {
 @inlinable
 var trimmed: String {
  replacingOccurrences(
   of: "\\s+$",
   with: "",
   options: .regularExpression
  )
 }

 @inlinable
 var withoutSpaces: String {
  replacingOccurrences(of: " ", with: "")
 }

 @inlinable
 var normalizingSpaces: String {
  map {
   guard $0 == "_" else { return $0 }
   return " "
  }
  .reduce(into: String()) { (results, element: Character) -> () in
   if let last = results.last {
    if last.isWhitespace, element.isWhitespace {
     return
    }
    if last.isLowercase, element.isUppercase {
     results += " \(element)"
     return
    }
   }

   results += "\(element)"
  }
  .trimmingCharacters(in: .whitespaces)
 }

 @inlinable
 static var comma: Self { "," }
 @inlinable
 static var period: Self { "." }
 @inlinable
 static var ellipsis: Self { "…" }
 @inlinable
 static var hyphen: Self { "-" }
 @inlinable
 static var space: Self { " " }
 @inlinable
 static var underscore: Self { "_" }
 @inlinable
 static var newline: Self { "\n" }
 @inlinable
 static var tab: Self { "\t" }
 @inlinable
 static var bullet: Self { "•" }
 @inlinable
 static var arrow: Self { "→" }
 @inlinable
 static var arrowRight: Self { "→" }
 @inlinable
 static var arrowLeft: Self { "←" }
 @inlinable
 static var fullstop: Self { "⇥" }
 @inlinable
 static var checkmark: Self { "✔︎" }
 @inlinable
 static var xmark: Self { "✘" }
 @inlinable
 static var `return`: Self { "⏎" }
 @inlinable
 static var plus: Self { "+" }
 @inlinable
 static var minus: Self { "-" }
 @inlinable
 static var equal: Self { "=" }
 @inlinable
 static var slash: Self { "/" }
 @inlinable
 static var backslash: Self { "\\" }
 @inlinable
 static var colon: Self { ":" }
 @inlinable
 static var semicolon: Self { ";" }

 @inlinable
 var range: Range<Index> { startIndex ..< endIndex }
}

// MARK: Operations
public extension [String] {
 func rename(
  _ base: Element,
  prefix: Element? = .none,
  includePrefixes: Bool = false,
  extension: Element? = .none,
  caseSensitive: Bool = false,
  offset: Int = 1
 ) -> Element {
  guard notEmpty else { return base }
  let adjustedOffset = 0 + offset
  var count: Int = adjustedOffset
  var elements =
   (caseSensitive ? sorted() : sorted().map { $0.lowercased() })
  for string in elements {
   let components =
    (caseSensitive ? string : string.lowercased())
     .components(separatedBy: caseSensitive ? base : base.lowercased())
   guard
    components.count == 2,
    components[0].isEmpty,
    var last = components.last
   else {
    elements.remove(at: 0)
    continue
   }
   if let `extension` {
    let `extension` =
     "\(caseSensitive ? `extension` : `extension`.lowercased())"
    last = last.replacingOccurrences(of: ".\(`extension`)", with: "")
   }
   let split = last.split(whereSeparator: \.isWhitespace)
   guard split.notEmpty else {
    count += 1
    continue
   }
   let first = String(split.first!)
   if
    let prefix,
    (caseSensitive ? first : first.lowercased())
    == (caseSensitive ? prefix : prefix.lowercased()) {
    if
     let last = split.last,
     let index = Int(last),
     index == count + 1 {
     count = index
     continue
    } else if split.count == 1 {
     count += 1
     continue
    }
   } else if
    split.count == 1 || includePrefixes,
    let last = split.last,
    let index = Int(last) {
    count = index == count + 1 ? index : count + 1
    continue
   }
   guard split.count == 1 || (split.count > 1 && includePrefixes) else {
    continue
   }
   count += 1
  }
  guard elements.notEmpty else { return base }
  //  guard elements.count > 1 else {
  //   return "\(base) \(prefix?.wrapped == nil ? adjustedOffset.description :
  //   prefix!)"
  //  }
  return """
  \(base) \
  \(prefix?.wrapped == nil ? .empty : "\(prefix!)\(count > 1 ? " " : .empty)")\
  \(count.description)
  """
 }
}

// MARK: - Splitting
public extension String {
 func partition(
  whereSeparator isSeparator: (Self.Element) throws
   -> Bool
 ) rethrows -> [SubSequence] {
  var parts: [SubSequence] = .empty
  if let firstIndex = try firstIndex(where: isSeparator) {
   let initialRange = startIndex ..< firstIndex
   parts.append(self[initialRange])

   var cursor: Self.Index = index(after: firstIndex)
   parts.append(self[firstIndex ..< cursor])

   while let nextIndex = try self[cursor...].firstIndex(where: isSeparator) {
    let base = self[cursor ..< nextIndex]
    if !base.isEmpty {
     parts.append(base)
    }

    cursor = index(after: nextIndex)
    parts.append(self[nextIndex ..< cursor])
   }

   if cursor < endIndex {
    parts.append(self[cursor...])
   }
   return parts
  } else {
   return [SubSequence(self)]
  }
 }
}

// MARK: - Matching
// https://talk.objc.io/episodes/S01E211-simple-fuzzy-matching
public extension String {
 func fuzzyMatches(_ needle: Self) -> Bool {
  if needle.isEmpty { return true }
  var remainder = needle[...].utf8
  for idx in utf8.indices {
   let char = utf8[idx]
   if char == remainder[remainder.startIndex] {
    remainder.removeFirst()
    if remainder.isEmpty { return true }
   }
  }
  return false
 }

 func fuzzyIndices(_ needle: String) -> [String.Index]? {
  if needle.isEmpty { return [] }
  var ixs: [Index] = []
  var remainder = needle[...].utf8
  for idx in utf8.indices {
   let char = utf8[idx]
   if char == remainder[remainder.startIndex] {
    ixs.append(idx)
    remainder.removeFirst()
    if remainder.isEmpty { return ixs }
   }
  }
  return nil
 }
}

// MARK: - Style
/// The casing of a string based on common formats.
public enum _StringCase: String, CaseIterable, Sendable, Codable {
 case type, camel, snake, identifier, kebab
}

public extension StringProtocol {
 typealias Case = _StringCase
}

public extension String {
 @inlinable
 var normalizedForCasing: String {
  map {
   guard $0 == "." || $0 == "_" || $0 == "-" else {
    if $0.isNewline { return Character("") }
    return $0
   }
   return " "
  }
  .reduce(into: String()) { (results, element: Character) -> () in
   if let last = results.last {
    if last.isWhitespace, element.isWhitespace {
     return
    }
    if last.isLowercase, element.isUppercase {
     results += " \(element)"
     return
    }
   }

   results += "\(element)"
  }
  .trimmingCharacters(in: .whitespacesAndNewlines)
 }

 /// A predictable recasing of the given string.
 func casing(_ case: Case) -> Self {
  assert(notEmpty)
  let splits = normalizedForCasing.split(separator: " ")
  switch `case` {
  case .type:
   return splits.map(\.capitalized).joined()
  case .camel:
   if splits.count > 1 {
    return splits[...1].first!.lowercased() +
     splits[1...].map(\.capitalized).joined()
   } else {
    return lowercased()
   }
  case .snake:
   return splits
    .map { $0.lowercased() }
    .joined(separator: "_")
  case .identifier:
   return splits
    .map { $0.lowercased() }
    .joined(separator: ".")
  case .kebab:
   return splits
    .map { $0.lowercased() }
    .joined(separator: "-")
  }
 }

 mutating func `case`(_ case: Case) {
  self = casing(`case`)
 }
}

public extension Substring {
 func casing(_ case: Case) -> Self {
  Self(String(self).casing(`case`))
 }

 mutating func `case`(_ case: Case) {
  self = casing(`case`)
 }
}

// MARK: - Hashing
#if canImport(CryptoKit)
import protocol CryptoKit.HashFunction
#elseif canImport(Crypto)
import protocol Crypto.HashFunction
#endif

#if canImport(CryptoKit) || canImport(Crypto)
public extension String {
 func hashString(with function: (some HashFunction).Type) -> String {
  function.hash(data: Data(utf8)).compactMap { String(format: "%02x", $0) }
   .joined()
 }
 func digest<A: HashFunction>(with function: A.Type) -> A.Digest {
  function.hash(data: Data(utf8))
 }
}
#endif
