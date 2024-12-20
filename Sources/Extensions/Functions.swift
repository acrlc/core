@inline(__always)
@discardableResult
public func withTask<Result>(
 after nanoseconds: Double,
 _ action: @escaping () async throws -> Result
) async throws -> Result {
 try await Task.sleep(nanoseconds: UInt64(nanoseconds))
 return try await action()
}

@available(macOS 13, iOS 16, *)
@inline(__always)
@discardableResult
public func withTask<Result>(
 after duration: Duration,
 _ action: @escaping () async throws -> Result
) async throws -> Result {
 try await Task.sleep(for: duration)
 return try await action()
}

@available(macOS 13, iOS 16, *)
@inline(__always)
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
@inline(__always)
public func sleep(for duration: Duration) async throws {
 try await Task.sleep(for: duration)
}

@available(macOS 13, iOS 16, *)
@inline(__always)
public func sleep<A: Clock>(
 for duration: A.Duration, tolerance: A.Duration? = nil, clock: A
) async throws {
 try await Task.sleep(for: duration, tolerance: tolerance, clock: clock)
}

@inline(__always)
public func sleep(for seconds: Double) async throws {
 try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
}

@inline(__always)
public func sleep(nanoseconds: UInt64) async throws {
 try await Task.sleep(nanoseconds: nanoseconds)
}
