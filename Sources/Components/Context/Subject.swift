/// A string that represents any person, place, or object
public struct Subject:
 RawRepresentable,
 ExpressibleByStringLiteral,
 ExpressibleByNilLiteral,
 Equatable {
 public let rawValue: String
 public init?(rawValue: String) {
  self.rawValue = rawValue
 }
}

public extension RawRepresentable where RawValue == String {
 init(stringLiteral: String) {
  self.init(rawValue: stringLiteral)!
 }
}

public extension RawRepresentable where RawValue == String {
 init(nilLiteral: ()) {
  self.init(rawValue: "")!
 }
}
