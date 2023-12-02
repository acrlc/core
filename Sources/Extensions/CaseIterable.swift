public extension CaseIterable where Self: Equatable, AllCases.Element == Self {
 var next: AllCases.Element? {
  guard
   let index = Self.allCases.firstIndex(of: self),
   let nextIndex =
   Self.allCases.index(index, offsetBy: 1, limitedBy: Self.allCases.endIndex)
  else { return nil }
  return Self.allCases[nextIndex]
 }
}
