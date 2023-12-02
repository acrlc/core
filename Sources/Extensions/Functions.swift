@inlinable
@discardableResult
public func withTask<Result>(
 after nanoseconds: Double,
 _ action: @escaping () async throws -> Result
) async throws -> Result {
 try await Task.sleep(nanoseconds: UInt64(nanoseconds))
 return try await action()
}

@available(macOS 13, iOS 16, *)
@inlinable
@discardableResult
public func withTask<Result>(
 after duration: Duration,
 _ action: @escaping () async throws -> Result
) async throws -> Result {
 try await Task.sleep(for: duration)
 return try await action()
}

@available(macOS 13, iOS 16, *)
@inlinable
public func sleep(for duration: Duration) async throws {
 try await Task.sleep(for: duration)
}

@inlinable
public func sleep(for nanoseconds: Double) async throws {
 try await Task.sleep(nanoseconds: UInt64(nanoseconds))
}

@inlinable
public func sleep(nanoseconds: UInt64) async throws {
 try await Task.sleep(nanoseconds: nanoseconds)
}
