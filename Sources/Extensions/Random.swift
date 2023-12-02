import Foundation
#if !os(Windows)
public extension Int {
 /// Returns a random Int point number between 0 and Int.max.
 static var random: Int {
  Int.random(n: Int.max)
 }

 /// Random integer between 0 and n-1.
 ///
 /// - Parameter n:  Interval max
 /// - Returns:      Returns a random Int point number between 0 and n max
 static func random(n: Int) -> Int {
  Int(arc4random_uniform(UInt32(n)))
 }

 ///  Random integer between min and max
 ///
 /// - Parameters:
 ///   - min:    Interval minimun
 ///   - max:    Interval max
 /// - Returns:  Returns a random Int point number between 0 and n max
 static func random(min: Int, max: Int) -> Int {
  Int.random(n: max - min + 1) + min
 }
}

// MARK: Double Extension

public extension Double {
 /// Returns a random floating point number between 0.0 and 1.0, inclusive.
 static var random: Double {
  Double(arc4random()) / 0xFFFF_FFFF
 }

 /// Random double between 0 and n-1.
 ///
 /// - Parameter n:  Interval max
 /// - Returns:      Returns a random double point number between 0 and n max
 static func random(min: Double, max: Double) -> Double {
  Double.random * (max - min) + min
 }
}

// MARK: Float Extension

public extension Float {
 /// Returns a random floating point number between 0.0 and 1.0, inclusive.
 static var random: Float {
  Float(arc4random()) / Float(Int32.max)
 }

 /// Random float between 0 and n-1.
 ///
 /// - Parameter n:  Interval max
 /// - Returns:      Returns a random float point number between 0 and n max
 static func random(min: Float, max: Float) -> Float {
  Float.random * (max - min) + min
 }
}

// MARK: CGFloat Extension
import struct Foundation.CGFloat
extension CGFloat {
 /// Randomly returns either 1.0 or -1.0.
 static var randomSign: CGFloat {
  (arc4random_uniform(2) == 0) ? 1.0 : -1.0
 }

 /// Returns a random floating point number between 0.0 and 1.0, inclusive.
 static var random: CGFloat {
  CGFloat(Float.random)
 }

 /// Random CGFloat between 0 and n-1.
 ///
 /// - Parameter n:  Interval max
 /// - Returns:      Returns a random CGFloat point number between 0 and n max
 static func random(min: CGFloat, max: CGFloat) -> CGFloat {
  CGFloat.random * (max - min) + min
 }
}
#endif
