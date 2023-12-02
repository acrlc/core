public extension Equatable {
 @inlinable static func == (lhs: Self?, rhs: Self) -> Bool {
  guard let lhs else { return false }
  return lhs == rhs
 }
}

public extension Optional where Wrapped: Sequence, Wrapped.Element: Equatable {
 @inlinable func contains(optional element: Wrapped.Element?) -> Bool {
  guard let element, let sequence = self else { return false }
  return sequence.contains(element)
 }
}
