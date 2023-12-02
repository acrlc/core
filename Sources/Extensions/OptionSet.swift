public struct OptionSetIterator<Set, Element>: IteratorProtocol
 where Set: OptionSet, Element: FixedWidthInteger, Set.RawValue == Element {
 private let value: Set
 private lazy var remainingBits = value.rawValue
 private var bitMask: Element = 1

 public init(element: Set) {
  self.value = element
 }

 public mutating func next() -> Set? {
  while self.remainingBits != 0 {
   defer { bitMask = bitMask &* 2 }
   if self.remainingBits & self.bitMask != 0 {
    self.remainingBits = self.remainingBits & ~self.bitMask
    return Set(rawValue: self.bitMask)
   }
  }
  return nil
 }
}

public extension OptionSet where RawValue: FixedWidthInteger {
 func makeIterator() -> OptionSetIterator<Self, RawValue> {
  OptionSetIterator(element: self)
 }
}
