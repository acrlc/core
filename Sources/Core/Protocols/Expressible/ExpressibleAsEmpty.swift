/// An object that can be expressed as empty
public protocol ExpressibleAsEmpty {
 static var empty: Self { get }
 var isEmpty: Bool { get }
}

public extension ExpressibleAsEmpty where Self: Equatable {
 @inlinable @_disfavoredOverload var isEmpty: Bool { self == .empty }
 @inlinable @_disfavoredOverload var notEmpty: Bool { !self.isEmpty }
}

public extension ExpressibleAsEmpty where Self: Collection {
 @inlinable var notEmpty: Bool { self.isEmpty == false }
 @inlinable var wrapped: Self? { self.isEmpty ? .none : self }
}

// MARK: Conformance Helpers

// FIXME: Conform to protocol `ExpressibleAsEmpty`
public extension ExpressibleByArrayLiteral {
 @inlinable @_disfavoredOverload static var empty: Self { [] }
}

public extension ExpressibleByStringLiteral {
 @_disfavoredOverload @inlinable static var empty: Self { "" }
}

public extension ExpressibleByDictionaryLiteral {
 @_disfavoredOverload @inlinable static var empty: Self { [:] }
}

// MARK: Conforming Types

extension String: ExpressibleAsEmpty {}

extension Dictionary: ExpressibleAsEmpty {}

extension Array: ExpressibleAsEmpty {}

extension ArraySlice: ExpressibleAsEmpty {}

extension Set: ExpressibleAsEmpty {}
