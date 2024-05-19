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
 static var comma: Self { "," }
 @inlinable
 static var period: Self { "." }
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

// MARK: - Casing
/// The casing of a string based on common formats.
public enum _StringCase: String, @unchecked Sendable, Codable {
 case type, camel, snake
}

public extension StringProtocol {
 typealias Case = _StringCase
}

public extension String {
 /// A predictable recasing of the given string.
 func casing(_ case: Case) -> Self {
  assert(notEmpty)
  switch `case` {
  case .type:
   @_transparent
   func `case`(with character: Character) -> Self {
    let splits = split(separator: character)
    return splits.map { substring -> Substring in
     if substring.first!.isUppercase {
      return substring
     }
     var substring = substring
     return substring.removeFirst().uppercased() + substring
    }.joined()
   }

   if contains(.space) {
    return `case`(with: .space)
   }

   if contains(.underscore) {
    return `case`(with: .underscore)
   }

   if let index = firstIndex(where: { $0.isLowercase }), index == startIndex {
    return String(
     self[...index].capitalized + self[self.index(after: index)...]
    )
   }
  case .camel:
   @_transparent
   func `case`(with character: Character) -> Self {
    var splits = split(separator: character)

    var first = splits.removeFirst()

    if first.first!.isUppercase {
     first = first.removeFirst().lowercased() + first
    }
    return first + splits.map { substring -> Substring in
     if substring.first!.isUppercase {
      return substring
     }
     var substring = substring
     return substring.removeFirst().uppercased() + substring
    }.joined()
   }

   if contains(.space) {
    return `case`(with: .space)
   }

   if contains(.underscore) {
    return `case`(with: .underscore)
   }

   if let index = firstIndex(where: { $0.isUppercase }), index == startIndex {
    return String(
     self[...index].lowercased() + self[self.index(after: index)...]
    )
   }
  case .snake:
   if contains(.space) {
    var splits = split(separator: .space)

    var first = splits.removeFirst()

    if first.first!.isUppercase {
     first = first.removeFirst().lowercased() + first
    }
    return first + splits.map { substring -> Substring in
     if substring.first!.isLowercase {
      return .underscore + substring
     }
     var substring = substring

     return .underscore + substring.removeFirst().lowercased() + substring
    }.joined()
   }

   if contains(where: \.isUppercase) {
    var copy = self
    if let index = firstIndex(where: { $0.isUppercase }), index == startIndex {
     copy = String(
      self[...index].lowercased() + self[self.index(after: index)...]
     )
    }

    var splits = copy.partition(whereSeparator: { $0.isUppercase })
    var index = splits.startIndex

    while index < splits.endIndex {
     let current = splits[index]
     if
      let previousIndex =
      splits.index(index, offsetBy: -1, limitedBy: splits.startIndex) {
      let previous = splits[previousIndex]
      if previous.count == 1, previous.first!.isUppercase {
       splits[index] = previous + current
       splits.remove(at: previousIndex)
      }
     }

     index += 1
    }

    return splits.map { $0.lowercased() }.joined(separator: .underscore)
   }
  }
  return self
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
#if os(Linux) && canImport(Crypto)
import protocol Crypto.HashFunction

public extension String {
 func hash(with function: (some HashFunction).Type) -> String {
  function.hash(data: Data(utf8)).compactMap { String(format: "%02x", $0) }
   .joined()
 }
}

#elseif canImport(CryptoKit)
import protocol CryptoKit.HashFunction

public extension String {
 func hash(with function: (some HashFunction).Type) -> String {
  function.hash(data: Data(utf8)).compactMap { String(format: "%02x", $0) }
   .joined()
 }
}
#endif
