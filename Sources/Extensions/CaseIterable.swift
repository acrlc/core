import Foundation

public extension CaseIterable where Self: Equatable, AllCases.Element == Self {
 @_disfavoredOverload
 var next: AllCases.Element? {
  guard
   let index = Self.allCases.firstIndex(of: self)
  else { return nil }
  let nextIndex = Self.allCases.index(index, offsetBy: 1)
  if nextIndex < Self.allCases.endIndex {
   return Self.allCases[nextIndex]
  } else {
   return nil
  }
 }
 
 @_disfavoredOverload
 var previous: AllCases.Element? {
  guard
   let index = Self.allCases.firstIndex(of: self)
  else { return nil }
  let nextIndex = Self.allCases.index(index, offsetBy: -1)
  if nextIndex >= Self.allCases.startIndex {
   return Self.allCases[nextIndex]
  } else {
   return nil
  }
 }
 
 @_disfavoredOverload
 @discardableResult
 mutating func toggle() -> Self {
  let next = next ?? Self.allCases.first!
  self = next
  return next
 }
}
