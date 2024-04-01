public protocol Node {
 /// The base collection for values that reflect this index
 associatedtype Base: Collection
 /// The index of the base collection in an array
 var index: Array.Index { get }
 /// The offset of a value within the base collection
 var offset: Base.Index { get }
}

public extension Node {
 static func < (lhs: Self, rhs: Self) -> Bool {
  lhs.index < rhs.index && lhs.offset < rhs.offset
 }

 static func == (lhs: Self, rhs: Self) -> Bool {
  lhs.index == rhs.index && lhs.offset == rhs.offset
 }
}

public protocol RecursiveValue {
 associatedtype Next: RecursiveValue
 var next: Next? { get }
}

public protocol ReflectiveValue {
 associatedtype Previous: RecursiveValue
 var previous: Previous? { get }
}

public protocol ConstrainedValue {
 associatedtype Start: RecursiveValue
 associatedtype End: RecursiveValue
 var start: Start { get }
 var end: End? { get }
}

/// A recursive index that can access values and other indices to allow
/// recursion on a base value
public protocol IndexicalValue:
 Node, RecursiveValue, ReflectiveValue, ConstrainedValue, ExpressibleAsStart {
 /// Refers to the type of index which is `Self`
 typealias Index = Self
 /// A base value for this index type
 typealias Value = Base.Element
 /// An array of base collections that allow values to be read on an index
 typealias Values = [Base]
 /// An array of indices used for recursing values
 typealias Indices = [[Self]]
 var values: Values { get set }
 var value: Value { get set }
 var indices: Indices { get set }
 /// The first prior, start index for this value
 var start: Index { get set }
 /// The previous index before this one
 var previous: Index? { get set }
 /// The next index after this one
 var next: Index? { get set }
 /// The last reachable index
 var end: Index? { get set }
 init()
}

public extension IndexicalValue {
 @inlinable static var start: Index { Self() }
}

public extension IndexicalValue {
 @_disfavoredOverload
 var base: Base {
  get { values[index] }
  mutating set { values[index] = newValue }
 }

 @_disfavoredOverload
 var elements: [Self] {
  get { indices[index] }
  mutating set { indices[index] = newValue }
 }

 @_disfavoredOverload
 /// The recursive limit of this index
 @inlinable var limit: Base.Index { self.base.endIndex }
 @_disfavoredOverload
 /// The recursive range of this index
 @inlinable var range: Range<Base.Index> { offset ..< limit }
}

public extension IndexicalValue
 where Base: RangeReplaceableCollection & MutableCollection {
 @_disfavoredOverload
 @_transparent
 var value: Value {
  get { values[index][offset] }
  mutating set { values[index][offset] = newValue }
 }
}

public extension IndexicalValue
 where Base.Index: Strideable, Base.Index.Stride: SignedInteger {
 @inlinable func contains(
  where condition: @escaping (Value) throws -> Bool
 ) rethrows -> Bool {
  for index in range where try condition(base[index]) { return true }
  return false
 }

 @inlinable func first(
  where condition: @escaping (Value) throws -> Bool
 ) rethrows -> Value? {
  for index in range {
   let value = base[index]
   guard try condition(value) else { continue }
   return value
  }
  return nil
 }

 @inlinable func index(
  where condition: @escaping (Value) throws -> Bool
 ) rethrows -> Index? where Base.Index == Int {
  for index in range {
   let value = base[index]
   guard try condition(value) else { continue }
   return elements[index]
  }
  return nil
 }
}

public extension IndexicalValue {
 @inlinable func forward(
  _ perform: @escaping (Index) throws -> ()
 ) rethrows {
  if let next = self.next {
   try perform(next)
   try next.forward(perform)
  }
 }

 @inlinable func forward(
  _ perform: @escaping (Index) async throws -> ()
 ) async rethrows {
  if let next = self.next {
   try await perform(next)
   try await next.forward(perform)
  }
 }

 @inlinable func reverse(
  _ perform: @escaping (Index) throws -> ()
 ) rethrows {
  while let previous = self.previous { try perform(previous) }
 }

 @inlinable func reverse(
  _ perform: @escaping (Index) async throws -> ()
 ) async rethrows {
  while let previous = self.previous { try await perform(previous) }
 }
}

/// Indexical value with storage for rebasing elements
@frozen public struct UnsafeRecursiveNode<
 Base: RangeReplaceableCollection & MutableCollection
>: IndexicalValue where Base.Index == Int {
 // - MARK: Starting properties

 @inlinable public init() {}

 public var index: Int = .zero
 public var offset: Values.Index = .zero
 public var startIndex: Values.Index = .zero
 
 public var _values: UnsafeMutableRawBufferPointer?

 public var values: Values {
  unsafeAddress {
   UnsafePointer(
    self._values.unsafelyUnwrapped
     .assumingMemoryBound(to: Values.self).baseAddress.unsafelyUnwrapped
   )
  }
  nonmutating unsafeMutableAddress {
   self._values.unsafelyUnwrapped
    .assumingMemoryBound(to: Values.self).baseAddress.unsafelyUnwrapped
  }
 }

 public var _indices: UnsafeMutableRawBufferPointer?

 public var indices: Indices {
  unsafeAddress {
   UnsafePointer(
    self._indices.unsafelyUnwrapped
     .assumingMemoryBound(to: Indices.self).baseAddress.unsafelyUnwrapped
   )
  }
  nonmutating unsafeMutableAddress {
   self._indices.unsafelyUnwrapped
    .assumingMemoryBound(to: Indices.self).baseAddress.unsafelyUnwrapped
  }
 }

 public var value: Value {
  unsafeAddress {
   withUnsafePointer(to: self.values[self.index][self.offset]) { $0 }
  }
  nonmutating unsafeMutableAddress {
   withUnsafeMutablePointer(to: &self.values[self.index][self.offset]) { $0 }
  }
 }

 /// The value checked, if removed in a separate process, etc.
 public var checkedValue: Value? {
  get {
   // note: this is an edge case but possible in some use cases
   assert(self.values.indices.contains(self.index))
   // this can happen when an index is escaped and the value no longer exists
   guard self.base.indices.contains(self.offset) else { return nil }
   return self.base[self.offset]
  }
  nonmutating set {
   assert(self.values.indices.contains(self.index))
   guard let newValue, self.base.indices.contains(self.offset) else { return }
   self.base[self.offset] = newValue
  }
 }
}

public extension UnsafeRecursiveNode {
 /// The recursive limit of this index
 var limit: Base.Index { self.base.endIndex }
 /// The recursive range of this index
 var range: Range<Base.Index> { self.offset ..< self.base.endIndex }

 var base: Base {
  unsafeAddress {
   withUnsafePointer(to: self.values[self.index]) { $0 }
  }
  nonmutating unsafeMutableAddress {
   withUnsafeMutablePointer(to: &self.values[self.index]) { $0 }
  }
 }

 var elements: [Index] {
  unsafeAddress {
   withUnsafePointer(to: self.indices[self.index]) { $0 }
  }
  nonmutating unsafeMutableAddress {
   withUnsafeMutablePointer(to: &self.indices[self.index]) { $0 }
  }
 }
}

public extension UnsafeRecursiveNode {
 var start: Self {
  unsafeAddress {
   withUnsafePointer(to: self.elements[startIndex]) { $0 }
  }
  nonmutating unsafeMutableAddress {
   withUnsafeMutablePointer(to: &self.elements[startIndex]) { $0 }
  }
 }

 var previousIndex: Int? {
  guard self.offset > base.startIndex else { return nil }
  return base.index(self.offset, offsetBy: -1)
 }

 var nextIndex: Int? {
  guard offset < base.index(base.endIndex, offsetBy: -1) else { return nil }
  return base.index(after: self.offset)
 }

 var next: Self? {
  get {
   guard let nextIndex else { return nil }
   return self.elements[nextIndex]
  }
  nonmutating set {
   guard let newValue, let nextIndex else { return }
   elements[nextIndex] = newValue
  }
 }

 var previous: Self? {
  get {
   guard let previousIndex else { return nil }
   return self.elements[previousIndex]
  }
  nonmutating set {
   guard let newValue, let previousIndex else { return }
   elements[previousIndex] = newValue
  }
 }

 var endIndex: Int? {
  guard elements.count > .zero else { return nil }
  return elements.endIndex
 }

 var end: Self? {
  get {
   guard let endIndex else { return nil }
   return self.elements[endIndex]
  }
  nonmutating set {
   guard let newValue, let endIndex else { return }
   self.elements[endIndex] = newValue
  }
 }

 var nextStartIndex: Int? {
  self.indices.index(
   start.index, offsetBy: 1,
   limitedBy: indices.index(indices.endIndex, offsetBy: -1)
  )
 }

 var nextStart: Self? {
  guard let nextStartIndex else { return nil }
  return self.indices[nextStartIndex].first
 }
}

public extension UnsafeRecursiveNode {
 /// Start here
 static func bind(
  base: Base,
  values: UnsafeMutablePointer<Values>, indices: UnsafeMutablePointer<Indices>
 ) {
  values.pointee.append(base)
  indices.pointee.append([Self()])

  indices.pointee[0][0]._values =
   withUnsafeMutableBytes(of: &values.pointee) { $0 }
  indices.pointee[0][0]._indices =
   withUnsafeMutableBytes(of: &indices.pointee) { $0 }
 }

 @discardableResult
 /// Start indexing from the current index
 func step(_ content: (Self) throws -> Value?) rethrows -> Value? {
  try content(self)
 }

 /// Initialize a new start index with a base collection
 @discardableResult
 func start(
  with base: Base, _ content: (Self) throws -> Value?
 ) rethrows -> Value? {
  let projection: Self = .start(from: self)
  let projectedIndex = projection.index
  self.values.append(base)
  self.indices.insert([projection], at: projectedIndex)

  if let result = try content(projection) {
   return result
  } else {
   self.values.remove(at: projectedIndex)
   self.indices.remove(at: projectedIndex)
   return nil
  }
 }

 /// Add base values to the current index
 func rebase(_ base: Base, _ content: (Self) throws -> Value?) rethrows {
  for element in base {
   let projectedIndex = self.elements.endIndex
   let projectedOffset = self.base.endIndex
   let projection: Self = .next(with: self)
   self.base.append(element)

   if try content(projection) != nil {
    self.elements.insert(projection, at: projectedIndex)
   } else {
    self.base.remove(at: projectedOffset)
   }
  }
 }

 /// Initializes a start index
 static func start(from start: Self) -> Self { Self(from: start) }
 @inlinable init(from start: Self) {
  self._values = start._values
  self._indices = start._indices
  self.index = start.index + 1
 }

 /// Initializes the next rebased index
 static func next(with start: Self) -> Self { Self(next: start) }
 @inlinable init(next start: Self) {
  self._values = start._values
  self._indices = start._indices
  self.index = start.index
  self.startIndex = start.offset
  // note: think about whether or not this is relevant
  if let previous {
   self.offset = previous.offset + 1
  } else {
   self.offset = base.endIndex
  }
 }
}

import Foundation
extension UnsafeRecursiveNode: @unchecked Sendable
 where Value: Sendable, Values.Index: Sendable {}
extension UnsafeRecursiveNode: Hashable {
 public func hash(into hasher: inout Hasher) {
  hasher.combine(self._values?.baseAddress)
  hasher.combine(self._indices?.baseAddress)
  hasher.combine(self.index)
  hasher.combine(self.offset)
 }
}
