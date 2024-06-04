#if canImport(Combine)
import Combine
#elseif os(WASI) || os(Windows) || os(Linux)
import OpenCombine
#endif

/// An object that can be converted into a dictionary from data
public protocol Serializable: AutoEncodable {
 static func serialize(_ output: AutoEncoder.Output) throws -> [String: Any]
}

extension Optional: Serializable where Wrapped: Serializable {
 public static func serialize(
  _ output: Wrapped.AutoEncoder.Output
 ) throws -> [String: Any] {
  try Wrapped.serialize(output)
 }
}

/// An object that can be converted from a dictionary into data
public protocol Deserializable: AutoDecodable {
 static func deserialize(_ input: [String: Any]) throws -> AutoDecoder.Input
}

extension Optional: Deserializable where Wrapped: Deserializable {
 public static func deserialize(
  _ input: [String: Any]
 ) throws -> AutoDecoder.Input {
  try Wrapped.deserialize(input)
 }
}

/// An object that conforms to `Serializable` & `Deserializable`
public typealias AutoSerializable = Serializable & Deserializable

import class Foundation.PropertyListSerialization

#if !os(WASI)
// MARK: PropertyList Conformances
public extension Serializable where Self: PlistCodable {
 static func serialize(_ output: AutoEncoder.Output) throws -> [String: Any] {
  var format: PropertyListSerialization.PropertyListFormat = .xml
  guard
   let output = try PropertyListSerialization
   .propertyList(
    from: output, options: .mutableContainersAndLeaves, format: &format
   ) as? [String: Any] else {
   throw EncodingError
    .invalidValue(
     output,
     EncodingError.Context(
      codingPath: [],
      debugDescription:
      """
      SerializationError: Invalid data input for \(Self.self)
      Please ensure that every property can be stored on a property list
      """
     )
    )
  }
  return output
 }
}

public extension Deserializable where Self: PlistCodable {
 static func deserialize(_ input: [String: Any]) throws -> AutoDecoder.Input {
  try PropertyListSerialization.data(
   fromPropertyList: input, format: .xml, options: .zero
  )
 }
}
#endif
