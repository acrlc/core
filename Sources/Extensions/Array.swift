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

#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS) && canImport(SwiftUI)
import SwiftUI

public extension Array {
 @discardableResult mutating func trim(_ index: Index) -> Self {
  guard endIndex > index else { return self }
  let indexes = IndexSet(integersIn: index ..< endIndex)
  remove(atOffsets: indexes)
  return self
 }
}
#endif
