public extension Comparable {
 func clamp(_ lhs: Self, _ rhs: Self) -> Self {
  min(max(self, lhs), rhs)
 }
}
