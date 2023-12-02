public protocol KeyIdentifiable {
 /// A type representing the stable identity of the entity associated with
 /// an instance.
 associatedtype Key: Hashable
 /// The stable identity of the entity associated with this instance.
 var key: Key { get }
}

#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)

public extension KeyIdentifiable where Self: Identifiable {
 @inlinable var id: Key { key }
}
#else
public extension KeyIdentifiable where Self: Identifiable {
 @inlinable var id: Key { key }
}
#endif
