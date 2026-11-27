#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

import os

@frozen
public struct Mutex<Value>: @unchecked Sendable {
  @usableFromInline
  internal final class _Storage: ManagedBuffer<os_unfair_lock_s, Value> {
    @inlinable
    deinit {
      let _ = withUnsafeMutablePointerToElements { elements in
        elements.deinitialize(count: 1)
      }
    }
  }

  @usableFromInline
  internal let _storage: _Storage

  @inlinable
  public init(_ initialValue: Value) {
    let storage = _Storage.create(minimumCapacity: 1) { _ in
      os_unfair_lock_s()
    }
    storage.withUnsafeMutablePointerToElements { elements in
      elements.initialize(to: initialValue)
    }
    _storage = unsafeDowncast(storage, to: _Storage.self)
  }

  @inlinable
  public func withLock<Result>(
    _ body: (inout Value) throws -> Result
  ) rethrows -> Result {
    try _storage.withUnsafeMutablePointers { lock, value in
      os_unfair_lock_lock(lock)
      defer { os_unfair_lock_unlock(lock) }
      return try body(&value.pointee)
    }
  }

  @inlinable
  public func withLockIfAvailable<Result>(
    _ body: (inout Value) throws -> Result
  ) rethrows -> Result? {
    try _storage.withUnsafeMutablePointers { lock, value in
      guard os_unfair_lock_trylock(lock) else { return nil }
      defer { os_unfair_lock_unlock(lock) }
      return try body(&value.pointee)
    }
  }
}