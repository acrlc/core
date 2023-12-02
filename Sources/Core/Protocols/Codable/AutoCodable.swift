import struct Foundation.Data
import struct Foundation.URL
#if canImport(Combine)
import Combine
#elseif os(WASI) || os(Windows) || os(Linux)
import OpenCombine
#endif

/// An object that conforms to `AutoDecodable` & `AutoEncodable`.
public protocol AutoCodable: AutoDecodable & AutoEncodable
 where AutoDecoder.Input == Data, AutoDecoder.Input == AutoEncoder.Output {
 static var decoder: AutoDecoder { get }
 static var encoder: AutoEncoder { get }
}

/// An object with a static, top level decoder.
public protocol AutoDecodable: Codable {
 associatedtype AutoDecoder: TopLevelDecoder
 /// Decoder used for decoding a `AutoDecodable` object.
 static var decoder: AutoDecoder { get }
}

/// An object with a static, top level encoder.
public protocol AutoEncodable: Codable {
 associatedtype AutoEncoder: TopLevelEncoder
 /// Encoder used for encoding a `AutoEncodable` object.
 static var encoder: AutoEncoder { get }
}

public extension AutoEncodable {
 func encoded() throws -> AutoEncoder.Output {
  try Self.encoder.encode(self)
 }

 var data: AutoEncoder.Output? { try? self.encoded() }
}

extension Optional: AutoEncodable where Wrapped: AutoEncodable {
 public static var encoder: Wrapped.AutoEncoder {
  Wrapped.encoder
 }
}

extension Optional: AutoDecodable where Wrapped: AutoDecodable {
 public static var decoder: Wrapped.AutoDecoder {
  Wrapped.decoder
 }
}

extension Optional: AutoCodable where Wrapped: AutoCodable {}

public extension AutoDecodable {
 init(_ input: AutoDecoder.Input) throws {
  self = try Self.decoder.decode(Self.self, from: input)
 }

 init(url: URL, options: Data.ReadingOptions = []) throws
  where AutoDecoder.Input == Data {
  let data = try Data(contentsOf: url, options: options)
  self = try Self.decoder.decode(Self.self, from: data)
 }
}

public extension AutoCodable {
 private var mirror: Mirror {
  Mirror(reflecting: self)
 }

 static var members: [String: String] {
  Dictionary(
   uniqueKeysWithValues:
   Mirror(reflecting: Self.self).children.map { label, _ in
    (label ?? .empty, String(describing: label))
   }
  )
 }

 var dictionary: [String: Any] {
  Dictionary(
   uniqueKeysWithValues:
   self.mirror.children.map { ($0.label!, $0.value) }
  )
 }
}

public extension TopLevelDecoder where Input == Data {
 func decode<A: Decodable>(
  contentOf url: URL,
  options: Data.ReadingOptions = .empty,
  _ type: A.Type
 ) throws -> A {
  try self.decode(type, from: Data(contentsOf: url, options: options))
 }
}

// MARK: Array Conformances

public struct ArrayEncoder<A: AutoEncodable>: TopLevelEncoder
 where A.AutoEncoder.Output == Data {
 public init() {}
 public func encode(_ value: some Encodable) throws -> Data {
  guard let values = value as? [A] else { fatalError() }
  return try Data(
   values.flatMap { try A.encoder.encode($0).map { $0 } }
  )
 }
}

public struct ArrayDecoder<A: AutoDecodable>: TopLevelDecoder
 where A.AutoDecoder.Input == Data {
 public init() {}
 static var size: Int { MemoryLayout<A>.size }
 public func decode<T>(
  _ type: T.Type, from data: Data
 ) throws -> T where T: Decodable {
  var data = data
  var elements = [A]()
  while !data.isEmpty {
   let bytes = data[0 ..< Self.size]
   data.removeSubrange(0 ..< Self.size)
   let value = try A.decoder.decode(A.self, from: Data(bytes))
   elements.append(value)
  }
  return elements as! T
 }
}

extension Array: AutoEncodable
 where Element: AutoEncodable, Element.AutoEncoder.Output == Data {
 public static var encoder: ArrayEncoder<Element> { ArrayEncoder<Element>() }
}

extension Array: AutoDecodable
 where Element: AutoDecodable, Element.AutoDecoder.Input == Data {
 public static var decoder: ArrayDecoder<Element> { ArrayDecoder<Element>() }
}

extension Array: AutoCodable where Element: AutoCodable {}

// MARK: Self Conformances
// TODO: Offer more nuanced control over encoders / decoders

public protocol StaticEncodable: AutoEncodable {
 static func encode(_ value: Self) throws -> Data
}

public protocol StaticDecodable: AutoDecodable {
 static func decode(_ data: Data) throws -> Self
}

public typealias StaticCodable = StaticDecodable & StaticEncodable

public struct StaticEncoder<A: StaticEncodable>: TopLevelEncoder {
 public init() {}
 public func encode(_ value: some Encodable) throws -> Data {
  try A.encode(value as! A)
 }
}

public extension StaticEncodable {
 static var encoder: StaticEncoder<Self> { StaticEncoder<Self>() }
}

public struct StaticDecoder<A: StaticDecodable>: TopLevelDecoder {
 public init() {}
 public func decode<T>(
  _ type: T.Type, from data: Data
 ) throws -> T where T: Decodable { try A.decode(data) as! T }
}

public extension StaticDecodable {
 static var decoder: StaticDecoder<Self> { StaticDecoder<Self>() }
}

public extension AutoDecodable {
 func decode(_ data: AutoDecoder.Input) throws -> Self {
  try Self.decoder.decode(Self.self, from: data)
 }
}

public extension AutoEncodable {
 func encode(_ value: Self) throws -> AutoEncoder.Output { try value.encoded() }
}
