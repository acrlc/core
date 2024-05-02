import Foundation
import enum Core.SystemInfo

public extension Collection where Index: Comparable {
 @inline(__always) mutating func dequeue(
  limit: Int? = nil,
  priority: TaskPriority = .medium,
  _ task: @Sendable @escaping (Element) async -> ()
 ) async where Element: Sendable, Self == Self.SubSequence {
  await withTaskGroup(of: Void.self) { group in
   let limit = limit ?? SystemInfo.coreCount
   var count: Int = .zero
   while !isEmpty {
    while count < limit, !isEmpty {
     count += 1
     let element = self.removeFirst()
     group.addTask(priority: priority) { await task(element) }
    }
    await group.next()
    count -= 1
   }
  }
 }

 /// Perform a task queue, limiting to a certain count or number of processors
 @inline(__always) func queue(
  limit: Int? = nil,
  priority: TaskPriority = .medium,
  _ task: @Sendable @escaping (Element) async -> ()
 ) async where Element: Sendable {
  await withTaskGroup(of: Void.self) { group in
   #if os(WASI)
   let limit = limit ?? 4
   #else
   let limit = limit ?? SystemInfo.coreCount
   #endif
   var offset = startIndex
   var count: Int = .zero
   while offset < endIndex {
    while count < limit, offset < endIndex {
     count += 1
     let element = self[offset]
     offset = index(after: offset)
     group.addTask(priority: priority) { await task(element) }
    }
    await group.next()
    count -= 1
   }
  }
 }

 @inline(__always) mutating func throwingDequeue(
  limit: Int? = nil,
  priority: TaskPriority = .medium,
  _ task: @Sendable @escaping (Element) async throws -> ()
 ) async rethrows where Element: Sendable, Self == Self.SubSequence {
  try await withThrowingTaskGroup(of: Void.self) { group in
   #if os(WASI)
   let limit = limit ?? 4
   #else
   let limit = limit ?? SystemInfo.coreCount
   #endif
   var count: Int = .zero
   while !isEmpty {
    while count < limit, !isEmpty {
     count += 1
     let element = self.removeFirst()
     group.addTask(priority: priority) { try await task(element) }
    }
    try await group.next()
    count -= 1
   }
  }
 }

 /// Perform a throwing task queue, limiting to a certain count or number of processors
 @inline(__always) func throwingQueue(
  limit: Int? = nil,
  priority: TaskPriority = .medium,
  _ task: @Sendable @escaping (Element) async throws -> ()
 ) async rethrows where Element: Sendable {
  try await withThrowingTaskGroup(of: Void.self) { group in
   #if os(WASI)
   let limit = limit ?? 4
   #else
   let limit = limit ?? SystemInfo.coreCount
   #endif
   var offset = startIndex
   var count: Int = .zero
   while offset < endIndex {
    while count < limit, offset < endIndex {
     count += 1
     let element = self[offset]
     offset = index(after: offset)
     group.addTask(priority: priority) { try await task(element) }
    }
    try await group.next()
    count -= 1
   }
  }
 }

 @discardableResult @inline(__always) mutating func dequeueResults<Result>(
  limit: Int? = nil,
  priority: TaskPriority = .medium,
  _ task: @Sendable @escaping (Element) async -> Result
 ) async -> [Result] where Element: Sendable, Self == Self.SubSequence {
  await withTaskGroup(of: Result.self, returning: [Result].self) { group in
   #if os(WASI)
   let limit = limit ?? 4
   #else
   let limit = limit ?? SystemInfo.coreCount
   #endif
   var results: [Result] = .empty
   var count: Int = .zero
   while !isEmpty {
    while count < limit, !isEmpty {
     count += 1
     let element = self.removeFirst()
     group.addTask(priority: priority) { await task(element) }
    }
    if let result = await group.next() { results.append(result); count -= 1 }
   }
   return results
  }
 }

 /// Perform a task queue, returning the accumulated results of the closure
 @inline(__always) @discardableResult func queueResults<Result>(
  limit: Int? = nil,
  priority: TaskPriority = .medium,
  _ task: @Sendable @escaping (Element) async -> Result
 ) async -> [Result] where Element: Sendable {
  await withTaskGroup(of: Result.self, returning: [Result].self) { group in
   #if os(WASI)
   let limit = limit ?? 4
   #else
   let limit = limit ?? SystemInfo.coreCount
   #endif
   var results: [Result] = .empty
   var offset = startIndex
   var count: Int = .zero
   while offset < endIndex {
    while count < limit, offset < endIndex {
     count += 1
     let element = self[offset]
     offset = index(after: offset)
     group.addTask(priority: priority) { await task(element) }
    }
    if let result = await group.next() { results.append(result); count -= 1 }
   }
   return results
  }
 }

 @discardableResult @inline(__always) mutating func dequeueThrowingResults<Result>(
  limit: Int? = nil,
  priority: TaskPriority = .medium,
  _ task: @Sendable @escaping (Element) async throws -> Result
 ) async rethrows -> [Result] 
 where Result: Sendable, Element: Sendable, Self == Self.SubSequence {
  try await withThrowingTaskGroup(of: Result.self, returning: [Result].self) { group in
   #if os(WASI)
   let limit = limit ?? 4
   #else
   let limit = limit ?? SystemInfo.coreCount
   #endif
   var results: [Result] = .empty
   var count: Int = .zero
   while !isEmpty {
    while count < limit, !isEmpty {
     count += 1
     let element = self.removeFirst()
     group.addTask(priority: priority) { try await task(element) }
    }
    if let result = try await group.next() { results.append(result); count -= 1 }
   }
   return results
  }
 }

 /// Perform a throwing task queue, returning the accumulated results of the closure
 @inline(__always) @discardableResult func queueThrowingResults<Result>(
  limit: Int? = nil,
  priority: TaskPriority = .medium,
  _ task: @Sendable @escaping (Element) async throws -> Result
 ) async rethrows -> [Result] where Result: Sendable, Element: Sendable {
  try await withThrowingTaskGroup(of: Result.self, returning: [Result].self) { group in
   #if os(WASI)
   let limit = limit ?? 4
   #else
   let limit = limit ?? SystemInfo.coreCount
   #endif
   var results: [Result] = .empty
   var offset = startIndex
   var count: Int = .zero
   while offset < endIndex {
    while count < limit, offset < endIndex {
     count += 1
     let element = self[offset]
     offset = index(after: offset)
     group.addTask(priority: priority) { try await task(element) }
    }
    if let result = try await group.next() { results.append(result); count -= 1 }
   }
   return results
  }
 }
}

// MARK: Uniquing
public extension RandomAccessCollection where Element: Hashable {
 func unique() -> [Iterator.Element] {
  var seen: Set<Element> = []
  return filter { seen.insert($0).inserted }
 }
}

public extension RandomAccessCollection {
 func uniqued<A>(on keyPath: KeyPath<Element, A>) -> [Iterator.Element]
  where A: Hashable {
  var seen: Set<A> = []
  return filter { seen.insert($0[keyPath: keyPath]).inserted }
 }
}

public extension Array where Element: Hashable {
 @discardableResult mutating func removeDuplicates() -> Self {
  self = unique()
  return self
 }
}

public extension Array where Element: Equatable {
 func unique() -> Self {
  var expression = self
  for element in self {
   while expression.count(for: element) > 1 {
    if let index = expression.firstIndex(where: { $0 == element }) {
     expression.remove(at: index)
    }
   }
  }
  return expression
 }

 func appendingUnique(_ contents: some Sequence<Element>) -> Self {
  var expression = self
  for element in contents where !contains(element) {
   expression.append(element)
  }
  return expression
 }

 @discardableResult mutating func removeDuplicates() -> Self {
  self = self.unique()
  return self
 }
}

// MARK: Unique Operations
public extension Sequence {
 func map(where condition: @escaping (Element) throws -> Bool) rethrows -> [Element]? {
  try self.compactMap { element in
   try condition(element) ? element : nil
  }.wrapped
 }

 func reduce(where condition: @escaping (Element) throws -> Bool) rethrows -> [Element] {
  try self.reduce([Element]()) {
   if let last = $0.last, try condition(last), try condition($1) {
    return $0
   }
   return $0 + [$1]
  }
 }
}

public extension Sequence where Element: Equatable {
 func reduce(element: Element) -> [Element] {
  self.reduce([Element]()) {
   if let last = $0.last, last == element, $1 == element {
    return $0
   }
   return $0 + [$1]
  }
 }
}

// using reduce to map elements with a given range
public extension Range where Bound: Strideable, Bound.Stride: SignedInteger {
 @inlinable func map<Element>(
  _ element: @escaping () throws -> Element?
 ) rethrows -> [Element] {
  try reduce(into: [Element]()) { results, _ in
   try results += [element()!]
  }
 }
}

// MARK: Sequence

// inserting is like joined but it replaces on condition
// required for converting model strings for using with css in `views.swift`
public extension RangeReplaceableCollection where Element: Equatable {
 @discardableResult
 mutating func insert(
  separator: Element, where condition: @escaping (Element) -> Bool
 ) -> Self {
  let indices = indices.dropFirst().dropLast()
  var inserted = 0

  for index in indices {
   let projectedIndex = self.index(index, offsetBy: inserted)
   guard condition(self[projectedIndex]) else { continue }
   self.insert(separator, at: projectedIndex)
   // if we insert one, we create an offset that must be compensate
   inserted += 1
  }
  return self
 }

 func inserting(
  separator: Element, where condition: @escaping (Element) -> Bool
 ) -> Self {
  var `self` = self
  return self.insert(separator: separator, where: condition)
 }

 func replacing(
  separator: Element, where condition: @escaping (Element) -> Bool
 ) -> Self {
  Self(
   map { condition($0) ? separator : $0 }
  )
 }
}

public extension RangeReplaceableCollection where Element: Equatable {
 @discardableResult
 mutating func insert(
  separator: Element,
  where condition: @escaping (Element) -> Bool,
  transforming: @escaping (Element) throws -> Element
 ) rethrows -> Self {
  let first = self[startIndex]

  // the first condition must be checked and replaced
  if condition(first) {
   remove(at: startIndex)
   try self.insert(transforming(first), at: startIndex)
  }

  let indices = indices.dropFirst().dropLast()
  var inserted = 0

  for index in indices {
   let projectedIndex = self.index(index, offsetBy: inserted)
   let element = self[projectedIndex]
   guard condition(element) else { continue }

   remove(at: index)
   try self.insert(transforming(element), at: index)
   self.insert(separator, at: projectedIndex)

   inserted += 1
  }
  return self
 }

 func inserting(
  separator: Element,
  where condition: @escaping (Element) -> Bool,
  transforming: @escaping (Element) throws -> Element
 ) rethrows -> Self {
  var `self` = self
  return try self.insert(
   separator: separator, where: condition, transforming: transforming
  )
 }
}

public extension Dictionary {
 @inlinable
 @discardableResult
 mutating func add(_ other: (key: Key, value: Value)) -> Self {
  self[other.key] = other.value
  return self
 }

 @inlinable
 func adding(_ other: (key: Key, value: Value)) -> Self {
  var `self` = self
  return self.add(other)
 }

 @inlinable
 @discardableResult
 static func += (_ self: inout Self, other: (key: Key, value: Value)) -> Self {
  self.add(other)
 }

 @inlinable
 static func + (_ self: Self, other: (key: Key, value: Value)) -> Self {
  self.adding(other)
 }
}

public extension RangeReplaceableCollection where Element: Equatable {
 // an attempt to wrap a collection given a delimiter and limit
 @inlinable func wrapping(
  to count: Int, delimiter: Element
 ) -> [SubSequence] {
  guard self.count > count else { return [self[startIndex ..< endIndex]] }
  var elements = [SubSequence]()
  var counted = 0
  var lastIndex = startIndex
  for index in indices {
   let element = self[index]
   if counted >= count {
    if element == delimiter {
     let newElements =
      self[lastIndex ..< self.index(index, offsetBy: elements.isEmpty ? 1 : 0)]
     elements.append(newElements)
     lastIndex = index
     counted = -1
    }
   }
   counted += 1
  }
  if !elements.isEmpty, counted > 0 {
   // remove duplicate subsequence
   elements.append(self[index(after: lastIndex) ..< endIndex])
  }
  return elements
 }
}

public extension RangeReplaceableCollection {
 /// Remove while the predicate is true and return the subsequence
 @inlinable @discardableResult mutating func remove(
  while predicate: (Element) throws -> Bool
 ) rethrows -> Self {
  if count == 1 {
   if try predicate(self[startIndex]) {
    defer { self.remove(at: startIndex) }
    return self
   } else {
    return .init()
   }
  } else {
   if let endIndex = try self.firstIndex(where: { try !predicate($0) }) {
    defer { self.removeSubrange(startIndex ..< endIndex) }
    return Self(self[startIndex ..< endIndex])
   } else {
    return self
   }
  }
 }

 /// Removes and returns all elements matching `condition`
 @inlinable mutating func drop(
  where condition: @escaping (Element) throws -> Bool
 ) rethrows -> Self {
  let copy = self
  var collection = Self()
  var offset = 0
  for index in indices where try condition(copy[index]) {
   collection.append(self.remove(at: self.index(index, offsetBy: offset)))
   offset -= 1
  }
  return collection
 }

 // Removes all elements matching the predicate and returns the collection
 @inlinable func removingAll(
  where predicate: @escaping (Element) throws -> Bool
 ) rethrows -> Self {
  var `self` = self
  try self.removeAll(where: predicate)
  return self
 }
}

extension RangeReplaceableCollection where Element: Equatable {}

public extension RangeReplaceableCollection where Element: Equatable {
 /// Groups subsequences of continous elements matching `condition`,
 /// ommiting the other elements and keeping indexes
 @inlinable func grouping(
  where condition: @escaping (Element) throws -> Bool
 ) rethrows -> [SubSequence] {
  var subsequences = [SubSequence]()

  var lastIndex: Index?
  for index in indices {
   let element = self[index]
   guard try condition(element) else {
    if let startIndex = lastIndex {
     subsequences.append(self[startIndex ..< index])
     lastIndex = nil
    }
    continue
   }
   lastIndex = index
  }
  return subsequences
 }

 // Removes single outside elements or returns and empty subsequence if
 // the count is less than three
 @inlinable var bracketsRemoved: SubSequence {
  guard count > 2 else { return SubSequence() }
  return self[index(after: startIndex) ..< index(endIndex, offsetBy: -1)]
 }
}

public extension Collection where Element: Equatable {
 @inlinable func count(for element: Element) -> Int {
  reduce(0) { $1 == element ? $0 + 1 : $0 }
 }

 @discardableResult
 @inlinable
 /// Matches sequential elements where the `condition` is true
 func matchingGroups(of element: Element) -> [ArraySlice<Self.Element>] {
  split(whereSeparator: { $0 != element }).removingAll(where: { $0.count == 1 })
 }

 @inlinable func separating(
  where condition: (Element) throws -> Bool
 ) rethrows -> [SubSequence] {
  try split(whereSeparator: condition)
 }

 @inlinable func count(
  where condition: @escaping (Element) throws -> Bool
 ) rethrows -> Int {
  try reduce(0) { try condition($1) ? $0 + 1 : $0 }
 }

 @inlinable func isRecursive(for element: Element) -> Bool {
  self.count(for: element).isMultiple(of: 2)
 }
}

public extension RangeReplaceableCollection {
 @inlinable
 @discardableResult
 /// Removes elements from the collection if result isn't `nil` and returns all results
 /// Like compact map but removes the original element from the collection
 mutating func invert<Result>(
  _ result: @escaping (Element) throws -> Result?
 ) rethrows -> [Result] {
  var elements = [Result]()
  var count: Int = .zero
  var removed: Int = .zero
  var offset = startIndex
  for element in self {
   if let newValue = try result(element) {
    elements.append(newValue)
    self.remove(at: index(offset, offsetBy: -removed))
    removed += 1
   }
   count += 1
   offset = index(startIndex, offsetBy: count)
  }
  // can return the difference
  //  try self.removeAll(
  //   where: {
  //    if let newValue = try result($0) {
  //     elements.append(newValue)
  //     return true
  //    } else {
  //     return false
  //    }
  //   }
  //  )
  return elements
 }
}

public extension Collection {
 @inlinable var range: Range<Index> { startIndex ..< endIndex }
}

// MARK: - Matching
public extension Collection where Element: Equatable {
 @_disfavoredOverload
 func fuzzyMatch(_ needle: Self) -> Bool {
  if needle.isEmpty { return true }
  var remainder = needle[...]
  for element in self {
   if element == remainder[remainder.startIndex] {
    remainder.removeFirst()
    if remainder.isEmpty { return true }
   }
  }
  return false
 }

 @_disfavoredOverload
 func fuzzyMatch(_ needle: Self) -> [Index]? {
  if needle.isEmpty { return [] }
  var ixs: [Index] = []
  var remainder = needle[...]
  for idx in indices {
   let element = self[idx]
   if element == remainder[remainder.startIndex] {
    ixs.append(idx)
    remainder.removeFirst()
    if remainder.isEmpty { return ixs }
   }
  }
  return nil
 }
}

// MARK: - Breaking
public extension Collection where Element: Equatable {
 // Breaks the sequence either at the last element that matches `lhs` or `rhs`
 // or the balanced subsequence
 func `break`(from lhs: Element, to rhs: Element) -> SubSequence? {
  // requirements
  guard self.count > 1 else {
   return nil
  }
  guard let lowerBound = self.firstIndex(of: lhs) else {
   return nil
  }
  var cursor: Index = self.index(after: lowerBound)
  var `break`: Index?
  while cursor < endIndex {
   let character = self[cursor]
   let subdata = self[lowerBound ..< cursor]
   cursor = self.index(after: cursor)
   if character == rhs || character == lhs { `break` = cursor }
   guard subdata.count(for: lhs) == subdata.count(for: rhs) else { continue }
   break
  }
  return self[lowerBound ..< (`break` ?? cursor)]
 }
}

public extension Collection {
 @inlinable
 func element(after index: Index) -> Element? {
  let nextIndex = self.index(after: index)
  guard nextIndex < endIndex else { return nil }
  return self[nextIndex]
 }
}
