public extension Dictionary {
 @inlinable mutating func append(contentsOf other: Self) {
  for (key, value) in other { self[key] = value }
 }

 @inlinable func appending(contentsOf other: Self) -> Self {
  var `self` = self
  self.append(contentsOf: other)
  return self
 }

 @inlinable static func + (lhs: Self, rhs: Self) -> Self {
  lhs.appending(contentsOf: rhs)
 }

 @inlinable static func += (lhs: inout Self, rhs: Self) {
  lhs.append(contentsOf: rhs)
 }
}

public extension Dictionary {
 @inlinable static func + (lhs: Self, rhs: [(Key, Value)]) -> Self {
  lhs.merging(rhs) { _, value in value }
 }

 @inlinable static func += (lhs: inout Self, rhs: [(Key, Value)]) {
  lhs.merge(rhs) { _, value in value }
 }
}
