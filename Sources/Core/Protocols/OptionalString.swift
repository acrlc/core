public protocol OptionalStringConvertible {
 var description: String? { get }
}

public extension OptionalStringConvertible {
 var description: String? { nil }
}

public extension Optional {
 var readable: String {
  self == nil ? "nil" : String(describing: self!).readable
 }
}

public extension String {
 var readable: String {
  if hasPrefix("Optional(") {
   return String(drop(while: { $0 != "(" }).dropFirst().dropLast()).readable
  }
  switch self {
  case .empty, "\"\"", "[]", "[:]": return ".empty"
  default: return self
  }
 }

 @inlinable var readableRemovingQuotes: String {
  let readable = readable
  if readable.first == "\"", readable.last == "\"" {
   return String(readable.dropFirst().dropLast())
  }
  return readable
 }
}
