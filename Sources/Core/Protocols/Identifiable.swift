#if !os(macOS) && !os(iOS) && !os(watchOS) && !os(tvOS)
public protocol Identifiable<ID> {
 /// A type representing the stable identity of the entity associated with
 /// an instance.
 associatedtype ID: Hashable

 /// The stable identity of the entity associated with this instance.
 var id: Self.ID { get }
}

public extension Identifiable where Self: AnyObject {
 /// The stable identity of the entity associated with this instance.
 var id: ObjectIdentifier { ObjectIdentifier(self) }
}

extension Never: Identifiable {
 public var id: Never { fatalError() }
}
#endif
