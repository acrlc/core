/// A string that describes any person, place, or object
public struct Descriptor:
 RawRepresentable,
 ExpressibleByStringLiteral,
 ExpressibleByNilLiteral,
 Equatable {
 public let rawValue: String
 public init?(rawValue: String) {
  self.rawValue = rawValue
 }
}
