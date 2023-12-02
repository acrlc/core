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

 @inlinable static var comma: Self { "," }
 @inlinable static var period: Self { "." }
 @inlinable static var hyphen: Self { "-" }
 @inlinable static var space: Self { " " }
 @inlinable static var underscore: Self { "_" }
 @inlinable static var newline: Self { "\n" }
 @inlinable static var tab: Self { "\t" }
 @inlinable static var bullet: Self { "•" }
 @inlinable static var arrow: Self { "→" }
 @inlinable static var arrowRight: Self { "→" }
 @inlinable static var arrowLeft: Self { "←" }
 @inlinable static var fullstop: Self { "⇥" }
 @inlinable static var checkmark: Self { "✔︎" }
 @inlinable static var xmark: Self { "✘" }
 @inlinable static var `return`: Self { "⏎" }
 @inlinable static var plus: Self { "+" }
 @inlinable static var minus: Self { "-" }
 @inlinable static var equal: Self { "=" }
 @inlinable var range: Range<Index> { startIndex ..< endIndex }
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
   guard components.count == 2,
         components[0].isEmpty,
         var last = components.last
   else {
    elements.remove(at: 0)
    continue
   }
   if let `extension` {
    let `extension` = "\(caseSensitive ? `extension` : `extension`.lowercased())"
    last = last.replacingOccurrences(of: ".\(`extension`)", with: "")
   }
   let split = last.split(whereSeparator: \.isWhitespace)
   guard split.notEmpty else {
    count += 1
    continue
   }
   let first = String(split.first!)
   if let prefix,
      (caseSensitive ? first : first.lowercased())
      == (caseSensitive ? prefix : prefix.lowercased()) {
    if let last = split.last,
       let index = Int(last),
       index == count + 1 {
     count = index
     continue
    } else if split.count == 1 {
     count += 1
     continue
    }
   } else if split.count == 1 || includePrefixes,
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
  //   return "\(base) \(prefix?.wrapped == nil ? adjustedOffset.description : prefix!)"
  //  }
  return """
  \(base) \
  \(prefix?.wrapped == nil ? .empty : "\(prefix!)\(count > 1 ? " " : .empty)")\
  \(count.description)
  """
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
/// The basic formatting of a string in a well-known form
/// `camel` for `camelCase`
/// `snake` for `snake_case`
/// `type` for `TypeCase`
public enum _StringCase: String, Sendable, Codable {
 case camel, snake, type
}

public extension StringProtocol {
 typealias Case = _StringCase
}

public extension String {
 mutating func `case`(_ case: Case) {
  switch `case` {
  case .type:
   @_transparent
   func `case`(with character: Character) -> Self {
    let splits = self.split(separator: character)
    return splits.map { substring -> Substring in
     if substring.first!.isUppercase {
      return substring
     }
     var substring = substring
     return substring.removeFirst().uppercased() + substring
    }.joined()
   }

   if self.contains(.space) {
    self = `case`(with: .space)
   }

   if self.contains(.underscore) {
    self = `case`(with: .underscore)
   }
   if self.first!.isLowercase {
    self = self.removeFirst().uppercased() + self
   }
  default: break
  }
 }

 func casing(_ case: Case) -> Self {
  assert(notEmpty)
  switch `case` {
  case .type:
   @_transparent
   func `case`(with character: Character) -> Self {
    let splits = self.split(separator: character)
    return splits.map { substring -> Substring in
     if substring.first!.isUppercase {
      return substring
     }
     var substring = substring
     return substring.removeFirst().uppercased() + substring
    }.joined()
   }

   if self.contains(.space) {
    return `case`(with: .space)
   }

   if self.contains(.underscore) {
    return `case`(with: .underscore)
   }
   if self.first!.isLowercase {
    var `self` = self
    return self.removeFirst().uppercased() + self
   }
  case .camel:
   @_transparent
   func `case`(with character: Character) -> Self {
    var splits = self.split(separator: character)

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

   if self.contains(.space) {
    return `case`(with: .space)
   }

   if self.contains(.underscore) {
    return `case`(with: .underscore)
   }

  case .snake: break // split by capital letters and / or underscores
  }
  return self
 }
}

public extension Substring {
 func casing(_ case: Case) -> Self {
  assert(!isEmpty)
  switch `case` {
  case .type:
   @_transparent
   func `case`(with character: Character) -> String {
    let splits = self.split(separator: character)
    return splits.map { substring -> Substring in
     if substring.first!.isUppercase {
      return substring
     }
     var substring = substring
     return substring.removeFirst().uppercased() + substring
    }.joined()
   }

   if self.contains(.space) {
    return Self(`case`(with: .space))
   }

   if self.contains(.underscore) {
    return Self(`case`(with: .underscore))
   }
   if self.first!.isLowercase {
    var `self` = self
    return self.removeFirst().uppercased() + self
   }
  case .camel:
   @_transparent
   func `case`(with character: Character) -> Self {
    var splits = self.split(separator: character)

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

   if self.contains(.space) {
    return `case`(with: .space)
   }

   if self.contains(.underscore) {
    return `case`(with: .underscore)
   }

  case .snake: break // split by capital letters and / or underscores
  }
  return self
 }
}

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
