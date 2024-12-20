#if canImport(Combine)
import Combine
#elseif os(WASI) || os(Windows) || os(Linux)
import OpenCombine
#endif

/// An object that can be converted into a dictionary from data
public protocol Serializable: AutoEncodable {
 associatedtype SerializedOutput
 static func serialize(_ output: AutoEncoder.Output) throws -> SerializedOutput
}

extension Optional: Serializable where Wrapped: Serializable {
 public static func serialize(
  _ output: Wrapped.AutoEncoder.Output
 ) throws -> Wrapped.SerializedOutput {
  try Wrapped.serialize(output)
 }
}

#if !os(WASI)
import class Foundation.PropertyListSerialization
// MARK: PropertyList Conformances
public extension Serializable where Self: PlistCodable {
 static func serialize(_ output: AutoEncoder.Output) throws -> SerializedOutput {
  var format: PropertyListSerialization.PropertyListFormat = .xml
  let plist = try PropertyListSerialization
  .propertyList(
   from: output, options: .mutableContainersAndLeaves, format: &format
  )
  guard
   let output = plist as? SerializedOutput else {
   throw EncodingError
    .invalidValue(
     output,
     EncodingError.Context(
      codingPath: [],
      debugDescription:
      """
      SerializationError: Invalid output (\(SerializedOutput.self)) for \
      \(Self.self)\nPlease ensure that the property list format matches that \
      of the desired output.\nProperty List Description:\n\(plist as! String)
      """
     )
    )
  }
  return output
 }
 static func serialize<A>(_ output: AutoEncoder.Output, as: A.Type) throws -> A {
  var format: PropertyListSerialization.PropertyListFormat = .xml
  guard
   let output = try PropertyListSerialization
   .propertyList(
    from: output, options: .mutableContainersAndLeaves, format: &format
   ) as? A else {
   throw EncodingError
    .invalidValue(
     output,
     EncodingError.Context(
      codingPath: [],
      debugDescription:
      """
      SerializationError: Invalid data input for \(Self.self)
      """
     )
    )
  }
  return output
 }
}
#endif

/// An object that can be converted from a dictionary into data
public protocol Deserializable: AutoDecodable {
 associatedtype SerializedInput
 static func deserialize(_ input: SerializedInput) throws -> AutoDecoder.Input
}

#if !os(WASI)
public extension Deserializable where Self: PlistCodable {
 static func deserialize(_ input: SerializedInput) throws -> AutoDecoder.Input {
  try PropertyListSerialization.data(
   fromPropertyList: input, format: .xml, options: .zero
  )
 }
}
#endif

extension Optional: Deserializable where Wrapped: Deserializable {
 public static func deserialize(
  _ input: Wrapped.SerializedInput
 ) throws -> AutoDecoder.Input {
  try Wrapped.deserialize(input)
 }
}

/// An object that conforms to `Serializable` & `Deserializable`
public protocol AutoSerializable: Serializable & Deserializable
where SerializedOutput == SerializedInput {}
