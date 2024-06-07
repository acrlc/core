/// A key used to persist objects related to a particular interface.
public struct InterfaceID:
 RawRepresentable, ExpressibleByStringLiteral, Hashable, Codable, Identifiable {
 public let rawValue: String

 public init(id: String? = nil, primary: String, secondary: String? = nil) {
  var string = primary
  if let secondary {
   string.append(".\(secondary)")
  }
  if let id {
   string.append(".\(id)")
  }
  self.init(rawValue: string)
 }

 public init(
  id: some CustomStringConvertible, primary: String, secondary: String? = nil
 ) {
  var string = primary
  if let secondary {
   string.append(".\(secondary)")
  }
  string.append(".\(id)")
  self.init(rawValue: string)
 }

 /// The substring after the last period mark, or the entire string if no
 /// separators exist.
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

 /// An optional primary string.
 public var primary: Self? {
  guard let index = rawValue.firstIndex(where: { $0 == "." }) else {
   return nil
  }
  return Self(rawValue: String(rawValue[..<index]))
 }

 /// An optional secondary string.
 public var secondary: Self? {
  guard rawValue.contains(".") else { return nil }
  let splits =
   rawValue.split(separator: ".", maxSplits: 3, omittingEmptySubsequences: true)
  return Self(rawValue: String(splits[1]))
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

 public var removingID: Self {
  guard
   let predicateIndex = rawValue.lastIndex(where: { $0 == "." }),
   let index =
   rawValue.index(
    predicateIndex, offsetBy: 1, limitedBy: rawValue.endIndex
   ) else {
   return self
  }
  return Self(rawValue: String(rawValue[...index]))
 }

 public var base: Self {
  guard let primary, let secondary else { return self }
  return Self(rawValue: primary.rawValue + "." + secondary.rawValue)
 }

 public mutating func removeID() {
  guard
   let predicateIndex = rawValue.lastIndex(where: { $0 == "." }),
   let index =
   rawValue.index(
    predicateIndex, offsetBy: 1, limitedBy: rawValue.endIndex
   ) else {
   return
  }
  self = Self(rawValue: String(rawValue[...index]))
 }

 public static func + (
  lhs: Self, rhs: some CustomStringConvertible
 ) -> Self {
  Self(rawValue: "\(lhs.rawValue).\(rhs.description)")
 }
 
 public func appending(
  _ rhs: some CustomStringConvertible
 ) -> Self {
  Self(rawValue: "\(self.rawValue).\(rhs.description)")
 }
}

extension InterfaceID: CustomStringConvertible {
 public var description: String { rawValue }
}
