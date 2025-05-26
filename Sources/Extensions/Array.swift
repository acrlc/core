public extension Array {
 subscript(first where: @escaping (Element) -> Bool) -> Element? {
  get { first(where: `where`) }
  mutating set {
   if let index = firstIndex(where: `where`) {
    guard let newValue else {
     self.remove(at: index)
     return
    }
    self[index] = newValue
   }
  }
 }
 
 @discardableResult
 mutating func removeFirst(
  where predicate: @escaping (Element) throws -> Bool
 ) rethrows -> Element? {
  guard let index = try firstIndex(where: predicate) else {
   return nil
  }
  return remove(at: index)
 }
}

public extension Array where Element: Equatable {
 mutating func removeAll(_ element: Element) {
  self.removeAll(where: { $0 == element })
 }
}

public extension RangeReplaceableCollection where Self: MutableCollection, Element: Hashable {
 @discardableResult mutating func appendUnique(_ element: Element) -> Self {
  if !contains(element) { append(element) }
  return self
 }

 @discardableResult func appendingUnique(_ element: Element) -> Self {
  var `self` = self
  return self.appendUnique(element)
 }
}

// MARK: Sorting
public extension Array {
 func sorted<Value: Comparable>(
  by keyPath: KeyPath<Element, Value>,
  comparator: (Value, Value) -> Bool = { $0 < $1 }
 ) -> Self {
  sorted(by: { comparator($0[keyPath: keyPath], $1[keyPath: keyPath]) })
 }
 
 mutating func sort<Value: Comparable>(
  by keyPath: KeyPath<Element, Value>,
  comparator: (Value, Value) -> Bool = { $0 < $1 }
 ) {
  sort(by: { comparator($0[keyPath: keyPath], $1[keyPath: keyPath]) })
 }
}
