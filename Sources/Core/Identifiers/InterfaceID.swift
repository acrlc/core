/// A key used to persist objects related to a particular interface.
public struct InterfaceID:
 RawRepresentable, ExpressibleByStringLiteral, Hashable, Codable, Identifiable {
 public let rawValue: String

 public var id: String {
  guard
   let predicateIndex = rawValue.lastIndex(where: { $0 == "." }),
   let index =
   rawValue.index(
    predicateIndex, offsetBy: 1, limitedBy: rawValue.endIndex
   ) else {
   return rawValue
  }
  return String(rawValue[index...])
 }

 public var subject: String? {
  guard let index = rawValue.firstIndex(where: { $0 == "." }) else {
   return nil
  }
  return String(rawValue[..<index])
 }

 public init(rawValue: String) {
  self.rawValue = rawValue
 }

 public init(_ rawValue: String) {
  self.rawValue = rawValue
 }

 public init(stringLiteral string: String) {
  self.init(string)
 }
}
