import struct Foundation.URLQueryItem
public extension Collection<URLQueryItem> {
 subscript(_ name: String) -> String? {
  first(where: { $0.name == name })?.value
 }
}

import struct Foundation.URL
extension URL: ExpressibleByStringLiteral {
 #if os(WASI)
 public init(resolved string: String) {
  self = URL(string: string) ?? URL(fileURLWithPath: string)
 }
 #else
 public init(resolved string: String) {
  self =
   URL(string: string) ??
   URL(fileURLWithPath: string).resolvingSymlinksInPath()
 }
 #endif
 public init(stringLiteral: StaticString) {
  self = URL(resolved: stringLiteral.description)
 }
}

extension URL: LosslessStringConvertible {
 public init?(_ description: String) {
  self = URL(resolved: description)
 }
}
