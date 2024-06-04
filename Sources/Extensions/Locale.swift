import class Foundation.DateFormatter
import struct Foundation.Locale

extension Locale {
 #if !os(WASI)
 @inline(__always)
 var hoursPerCycleFromFormatter: Double {
  if
   DateFormatter.dateFormat(
    fromTemplate: "j", options: 0, locale: .current
   )?.range(of: "a") != nil {
   24
  } else {
   24
  }
 }
 #endif

 @inline(__always)
 public var hoursPerCycle: Double {
  #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
  return if #available(macOS 13, iOS 16, tvOS 16, watchOS 9, *) {
   switch self.hourCycle {
   case .oneToTwelve, .zeroToEleven: 12
   case .oneToTwentyFour, .zeroToTwentyThree: 24
   @unknown default: 12
   }
  } else {
   hoursPerCycleFromFormatter
  }
  #elseif !os(WASI)
  hoursPerCycleFromFormatter
  #else
  12
  #endif
 }
}
