import struct Foundation.UUID
extension UUID: @retroactive ExpressibleByNilLiteral {
 public init(nilLiteral _: ()) { self.init() }
}

extension RawRepresentable where RawValue: ExpressibleAsEmpty {
 init(nilLiteral _: ()) { self.init(rawValue: .empty)! }
}

import protocol Core.ExpressibleAsEmpty
extension Bool: @retroactive ExpressibleByNilLiteral {
 @inlinable public init(nilLiteral _: ()) { self.init(false) }
}

import protocol Core.Infallible
extension Bool: @retroactive Infallible {
 @inlinable public static var defaultValue: Bool { false }
}
