import struct Foundation.UUID
extension UUID: ExpressibleByNilLiteral {
 public init(nilLiteral _: ()) { self.init() }
}

extension RawRepresentable where RawValue: ExpressibleAsEmpty {
 init(nilLiteral _: ()) { self.init(rawValue: .empty)! }
}

import protocol Core.ExpressibleAsEmpty
extension Bool: ExpressibleByNilLiteral {
 @inlinable public init(nilLiteral _: ()) { self.init(false) }
}

import protocol Core.Infallible
extension Bool: Infallible {
 @inlinable public static var defaultValue: Bool { false }
}
