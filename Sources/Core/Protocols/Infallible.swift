/// An object that has a default value
public protocol Infallible {
 static var defaultValue: Self { get }
}

extension Optional: Infallible where Wrapped: Infallible {
 @inlinable public var unwrapped: Wrapped { self ?? .defaultValue }
 @inlinable public static var defaultValue: Wrapped? { Wrapped.defaultValue }
}

import struct Foundation.UUID
extension UUID: Infallible {
 @inlinable public static var defaultValue: Self {
  Self(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))
 }
}
