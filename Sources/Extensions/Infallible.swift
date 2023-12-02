import protocol Core.Infallible
extension Optional where Wrapped: Infallible {
 @inlinable func unwrap(_ other: Wrapped) -> Wrapped {
  self == nil ? .defaultValue : other
 }

 @inlinable func unwrap(_ other: @escaping (Wrapped) -> (Wrapped)) -> Wrapped {
  self == nil ? .defaultValue : other(self!)
 }
}

public extension Infallible where Self: Equatable {
 @inlinable
 /// An assertion that throws if value is default
 @discardableResult func throwing(_ error: Error? = .none) throws -> Self {
  guard self != .defaultValue else {
   throw error ?? UnwrapError.reason("Expected condition wasn't met")
  }
  return self
 }

 @inlinable
 @discardableResult
 func throwing(reason: String) throws -> Self {
  guard self != .defaultValue else {
   throw UnwrapError.reason(reason)
  }
  return self
 }
}

import protocol Core.ExpressibleAsEmpty
public extension ExpressibleAsEmpty where Self: Equatable {
 @inlinable
 @discardableResult func `throws`<A: Error>(_ error: A) throws -> A {
  guard notEmpty else { throw error }
  return error
 }
}

public extension Collection {
 @inlinable
 /// Throws a consistent error when the count is not within the given range
 func `throws`<A: Error>(_ range: Range<Int>, _ lower: A, _ upper: A) throws {
  let count = count
  guard count >= range.lowerBound else {
   guard count <= range.upperBound else { throw upper }
   throw lower
  }
 }
}

public extension Range {
 @inlinable
 /// Throws a consistent error when the count is not within the given range
 func containsThrowing<A: Error>(
  _ bound: Bound, _ lower: A, _ upper: A
 ) throws -> Bool {
  guard bound >= lowerBound else {
   guard bound <= upperBound else { throw upper }
   throw lower
  }
  return true
 }
}
