import struct Foundation.Date

import protocol Core.Infallible
extension Date: @retroactive Infallible {
 @_disfavoredOverload
 @inlinable public static var defaultValue: Self { .init() }
}

extension Date: @retroactive ExpressibleByNilLiteral {
 @inlinable public init(nilLiteral: ()) { self.init() }
}

import protocol Core.Randomizable
public extension Date {
 /// Initialize a date within a specific range based on 'second' intervals
 /// The default is 1 minute to 27 days in the past, useful for creating timelines
 @inlinable static func random(
  _ range: Range<Int> = -2_332_800 ..< -60
 ) -> Self {
  Date(timeIntervalSinceNow: Double(range.randomElement()!))
 }
}

extension Date: @retroactive Randomizable {
 @inlinable public mutating func randomize() {
  self = .random()
 }
}
