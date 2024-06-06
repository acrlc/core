import struct Foundation.CharacterSet

public extension Character {
 var isAlphaNumeric: Bool {
  guard let scalar = unicodeScalars.first else { return false }
  return CharacterSet.alphanumerics.contains(scalar)
 }

 var isUnderscore: Bool {
  guard let scalar = unicodeScalars.first else { return false }
  return scalar == "_"
 }

 mutating func uppercase() {
  self = Character(uppercased())
 }
}

public extension Character {
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
}

import protocol Core.ExpressibleAsEmpty
extension Character: ExpressibleAsEmpty {
 public static var empty: Character { Character("\0") }
 public var isEmpty: Bool { self == .empty }
}
