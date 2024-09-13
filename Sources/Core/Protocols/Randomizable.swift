import struct Foundation.UUID

public protocol Randomizable: Infallible {
 mutating func randomize()
}

public extension Randomizable {
 static var random: Self {
  var `self` = Self.defaultValue
  self.randomize()
  return self
 }
}

extension UUID: Randomizable {
 public mutating func randomize() {
  self = UUID()
 }
}

#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)

public protocol MutableIdentity: Identifiable {
 override var id: ID { get set }
}

public extension Randomizable where Self: MutableIdentity {
 static func random(_ id: ID) -> Self {
  var copy = Self.defaultValue
  copy.id = id
  copy.randomize()
  return copy
 }
}
#else
public protocol MutableIdentity: Identifiable {
 override var id: ID { get set }
}

public extension Infallible where Self: MutableIdentity {
 init(identifying id: ID) {
  self = .defaultValue
  self.id = id
 }
}

public extension Randomizable where Self: MutableIdentity {
 static func random(_ id: ID) -> Self {
  var random = Self(identifying: id)
  random.randomize()
  return random
 }
}
#endif
