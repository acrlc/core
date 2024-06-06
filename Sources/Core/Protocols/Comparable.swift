infix operator !<
infix operator !>
public extension Comparable {
 static func !< (lhs: Self, rhs: Self) -> Bool {
  !(lhs < rhs)
 }

 static func !> (lhs: Self, rhs: Self) -> Bool {
  !(lhs > rhs)
 }
}
