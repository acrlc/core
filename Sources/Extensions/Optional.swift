import protocol Foundation.LocalizedError
public enum UnwrapError: LocalizedError, CustomStringConvertible {
 case `default`(file: String, line: Int), reason(
  String,
  file: String,
  line: Int
 )
 @inlinable
 public var errorDescription: String? {
  switch self {
  case .default(let file, let line):
   "\(file):\(line): Unexpectedly found nil while unwrapping an Optional value"
  case .reason(let reason, let file, let line):
   "\(file):\(line): \(reason)"
  }
 }
}

public extension Optional {
 @inlinable
 var isNil: Bool { self == nil }
 @inlinable
 var notNil: Bool { self != nil }
 @inlinable
 func wrap(to other: Self) -> Self {
  self == nil ? other : self
 }

 @inlinable
 func wrap(to other: Self) async -> Self {
  self == nil ? other : self
 }

 @inlinable
 func wrap(_ other: @escaping (Wrapped) -> (Wrapped)) -> Self {
  self == nil ? self : other(self!)
 }

 @inlinable
 func wrap(_ other: @escaping (Wrapped) -> (Wrapped)) async -> Self {
  self == nil ? self : other(self!)
 }

 @inlinable
 @discardableResult
 func throwing(
  _ error: Error? = .none, file: String = #file, line: Int = #line
 ) throws -> Wrapped {
  guard let self else {
   throw error ?? UnwrapError.default(
    file: file,
    line: line
   )
  }
  return self
 }

 @inlinable
 @discardableResult
 func throwing(
  reason: String, file: String = #file, line: Int = #line
 ) throws -> Wrapped {
  guard let self else {
   throw UnwrapError.reason(reason, file: file, line: line)
  }
  return self
 }

 @inlinable
 @discardableResult
 func negating(_ error: Error) async throws -> Bool {
  guard self == nil else {
   throw error
  }
  return true
 }

 @inlinable
 @discardableResult
 func negating(_ error: Error) throws -> Bool {
  guard self == nil else {
   throw error
  }
  return true
 }
}
