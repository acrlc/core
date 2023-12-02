import protocol Foundation.LocalizedError
#if os(WASI) || os(Windows)
public extension Error {
 @_disfavoredOverload
 // An explicit error message
 var message: String {
  guard let self = self as? any LocalizedError else {
   return "\(self)"
  }
  return self.errorDescription ??
   self.failureReason ??
   self.localizedDescription
 }
}
#else
import class Foundation.NSError
import struct Foundation.POSIXError
public extension Error {
 @_disfavoredOverload
 // An explicit error message
 var message: String {
  guard let self = self as? any LocalizedError else {
   #if os(macOS) || os(iOS)
   if #available(macOS 11.3, iOS 14.5, *) {
    let error = self as NSError
    if let posix = (error.underlyingErrors.first as? POSIXError) {
     return posix.localizedDescription
    }
   }
   #endif
   return "\(self)"
  }
  return self.errorDescription ?? self.failureReason ??
   self.localizedDescription
 }
}
#endif

public extension Error {
 /// Determines the POSIX return code
 @_disfavoredOverload
 var _code: Int { 1 }
 /// Describes the error in most cases where `errorDescription` might be
 /// incompatible
 /// - Note: but must conform to `CustomStringConvertible` or `LocalizedError`
 @_disfavoredOverload
 var description: String { message }
}
