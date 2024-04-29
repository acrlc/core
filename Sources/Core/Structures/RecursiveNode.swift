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

public protocol RecursiveElement {
 associatedtype Next: RecursiveElement
 var next: Next? { get }
}

public protocol ReflectiveElement {
 associatedtype Previous: RecursiveElement
 var previous: Previous? { get }
}

public protocol ConstrainedElement {
 associatedtype Start: RecursiveElement
 associatedtype End: RecursiveElement
 var start: Start { get }
 var end: End? { get }
}

/// A recursive index that can access values and other indices to allow
/// recursion on a base value
public protocol IndexicalElement:
 Node, RecursiveElement, ReflectiveElement, ConstrainedElement,
 ExpressibleAsStart {
 /// Refers to the type of index which is `Self`
 typealias Index = Self
 typealias Element = Base.Element
 /// An array of indices used for recursing values
 typealias Indices = [Self]
 var element: Element { get set }
 var base: Base { get set }
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

public extension IndexicalElement {
 @inlinable
 static var start: Index { Self() }
}

public extension IndexicalElement {
 @inlinable
 func forward(
  _ perform: @escaping (Index) throws -> ()
 ) rethrows {
  if let next {
   try perform(next)
   try next.forward(perform)
  }
 }

 @inlinable
 func forward(
  _ perform: @escaping (Index) async throws -> ()
 ) async rethrows {
  if let next {
   try await perform(next)
   try await next.forward(perform)
  }
 }

 @inlinable
 func reverse(
  _ perform: @escaping (Index) throws -> ()
 ) rethrows {
  if let previous {
   try perform(previous)
   try previous.reverse(perform)
  }
 }

 @inlinable
 func reverse(
  _ perform: @escaping (Index) async throws -> ()
 ) async rethrows {
  if let previous {
   try await perform(previous)
   try await previous.reverse(perform)
  }
 }
}

/// Indexical value with storage for rebasing elements
@frozen
public struct UnsafeRecursiveNode<
 Base: RangeReplaceableCollection & MutableCollection
>: IndexicalElement where Base.Index == Int {
 // - MARK: Starting properties

 @inlinable
 public init() {}

 public var index: Int = .zero
 public var offset: Indices.Index = .zero
 public var startIndex: Int = .zero

 public var _base: UnsafeMutablePointer<Base>?

 public var base: Base {
  unsafeAddress {
   UnsafePointer(_base.unsafelyUnwrapped)
  }
  nonmutating unsafeMutableAddress {
   _base.unsafelyUnwrapped
  }
 }

 public var _indices: UnsafeMutablePointer<Indices>?

 public var indices: Indices {
  unsafeAddress {
   UnsafePointer(_indices.unsafelyUnwrapped)
  }
  nonmutating unsafeMutableAddress {
   _indices.unsafelyUnwrapped
  }
 }

 public var element: Element {
  get { base[offset] }
  nonmutating set { base[offset] = newValue }
 }

 /// The value checked, if removed in a separate process, etc.
 public var checkedElement: Element? {
  get {
   // this can happen when an index is escaped and the value no longer exists
   guard offset < base.endIndex else {
    return nil
   }
   return base[offset]
  }
  nonmutating set {
   guard let newValue, offset < base.endIndex else {
    return
   }
   base[offset] = newValue
  }
 }
}

public extension UnsafeRecursiveNode {
 /// The recursive range of this index
 var range: Range<Int>? {
  guard let endIndex else {
   return nil
  }
  return index ..< endIndex
 }

 /// The recursive limit of this index
 var limit: Int? { range?.upperBound }
}

public extension UnsafeRecursiveNode {
 @inlinable
 func contains(
  where condition: @escaping (Element) throws -> Bool
 ) rethrows -> Bool {
  for element in base[self.offset...] where try condition(element) {
   return true
  }
  return false
 }

 @inlinable
 func first(
  where condition: @escaping (Element) throws -> Bool
 ) rethrows -> Element? {
  for index in indices[self.index...] where try condition(index.element) {
   return index.element
  }
  return nil
 }

 @inlinable
 func index(
  where condition: @escaping (Element) throws -> Bool
 ) rethrows -> Index? {
  for index in indices[self.index...] where try condition(index.element) {
   return index
  }
  return nil
 }
}

public extension UnsafeRecursiveNode {
 var start: Self {
  get {
   indices[startIndex]
  }
  nonmutating set {
   self.indices[startIndex] = newValue
  }
 }

 var previousIndex: Base.Index? {
  guard index > indices.startIndex else {
   return nil
  }
  return index - 1
 }

 var previous: Self? {
  get {
   guard let previousIndex else {
    return nil
   }
   return indices[previousIndex]
  }
  nonmutating set {
   guard let newValue, let previousIndex else {
    return
   }
   indices[previousIndex] = newValue
  }
 }

 var nextIndex: Base.Index? {
  guard index < indices.endIndex else {
   return nil
  }
  return indices.index(index, offsetBy: 1, limitedBy: indices.endIndex - 1)
 }

 var next: Self? {
  get {
   guard let nextIndex else {
    return nil
   }
   return indices[nextIndex]
  }
  nonmutating set {
   guard let newValue, let nextIndex else {
    return
   }
   indices[nextIndex] = newValue
  }
 }

 var nextStart: Self? {
  guard let nextStartIndex else {
   return nil
  }
  return indices[nextStartIndex]
 }

 var endIndex: Int? {
  guard indices.count > 1, index != indices.endIndex else { return nil }
  if let nextStartIndex {
   return indices.index(before: nextStartIndex)
  }
  return indices.index(before: indices.endIndex)
 }

 var end: Self? {
  get {
   guard let endIndex else {
    return nil
   }
   return indices[endIndex]
  }
  nonmutating set {
   guard let newValue, let endIndex else {
    return
   }
   self.indices[endIndex] = newValue
  }
 }

 var nextStartIndex: Int? {
  guard let nextIndex, index < nextIndex else {
   return nil
  }
  return indices[(index + 1)...].firstIndex(where: { $0.index == .zero })
 }
}

public extension UnsafeRecursiveNode {
 /// Start here
 static func bind(
  base: Base,
  basePointer: UnsafeMutablePointer<Base>,
  indicesPointer: UnsafeMutablePointer<Indices>
 ) {
  basePointer.pointee.append(contentsOf: base)
  indicesPointer.pointee.append(Self())

  indicesPointer.pointee[0]._base = basePointer
  indicesPointer.pointee[0]._indices = indicesPointer
 }

 @_disfavoredOverload
 @discardableResult
 /// Start indexing from the current index
 func step(_ content: (Self) throws -> Element?) rethrows -> Element? {
  try content(self)
 }

 @_disfavoredOverload
 /// Add base values to the current index
 func rebase(_ elements: Base, _ content: (Self) throws -> Element?) rethrows {
  for element in elements {
   let projectedIndex = indices.endIndex
   let projectedOffset = base.endIndex

   base.append(element)

   var projection: Self = .next(with: self)
   projection.index = projectedIndex
   projection.offset = projectedOffset

   if try content(projection) != nil {
    indices.insert(projection, at: projectedIndex)
   } else if projectedOffset < base.endIndex {
    base.remove(at: projectedOffset)
   }
  }
  
  @discardableResult
  /// Start indexing from the current index
  func step(_ content: (Self) async throws -> Element?) async rethrows
  -> Element? {
   try await content(self)
  }
  
  /// Add base values to the current index
  func rebase(
   _ elements: Base,
   _ content: (Self) async throws -> Element?
  ) async rethrows {
   for element in elements {
    let projectedIndex = indices.endIndex
    let projectedOffset = base.endIndex
    base.append(element)
    
    var projection: Self = .next(with: self)
    projection.index = projectedIndex
    projection.offset = projectedOffset
    
    if try await content(projection) != nil {
     indices.insert(projection, at: projectedIndex)
    } else if projectedOffset < base.endIndex {
     base.remove(at: projectedOffset)
    }
   }
  }
 }

 /// Initializes the next rebased index
 static func next(with start: Self) -> Self { Self(next: start) }
 @inlinable
 init(next start: Self) {
  _base = start._base
  _indices = start._indices
  startIndex = start.index
 }
}

import Foundation
extension UnsafeRecursiveNode: @unchecked Sendable
 where Element: Sendable, Base.Index: Sendable {}
extension UnsafeRecursiveNode: Hashable {
 public func hash(into hasher: inout Hasher) {
  hasher.combine(_base)
  hasher.combine(offset)
 }
}
