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
@discardableResult
public func withTask<A: Clock, Result>(
 after duration: A.Duration, tolerance: A.Duration? = nil,
 clock: A,
 _ action: @escaping () async throws -> Result
) async throws -> Result {
 try await Task.sleep(for: duration, tolerance: tolerance, clock: clock)
 return try await action()
}

@available(macOS 13, iOS 16, *)
@inlinable
public func sleep(for duration: Duration) async throws {
 try await Task.sleep(for: duration)
}

@available(macOS 13, iOS 16, *)
@inlinable
public func sleep<A: Clock>(
 for duration: A.Duration, tolerance: A.Duration? = nil, clock: A
) async throws {
 try await Task.sleep(for: duration, tolerance: tolerance, clock: clock)
}

@inlinable
public func sleep(for nanoseconds: Double) async throws {
 try await Task.sleep(nanoseconds: UInt64(nanoseconds))
}

@inlinable
public func sleep(nanoseconds: UInt64) async throws {
 try await Task.sleep(nanoseconds: nanoseconds)
}
