public struct EmptyID: Hashable, CustomStringConvertible, ExpressibleAsEmpty {
 public static let empty = Self()
 public var isEmpty: Bool { true }
 public var placeholder: String?
 public var description: String { placeholder ?? .empty }
}

public extension EmptyID {
 init(placeholder: String) { self.placeholder = placeholder }
}
