import Testing
@testable import Mutex
import Foundation

enum TestError: Error, Equatable {
    case boom
}

@Suite("Mutex Tests")
class MutexTests {
    @Test("Test Mutex.withLock unlocks when body throws")
    func mutexWithLockThrows() {
        let mutex = Mutex("hi")

        #expect(throws: TestError.boom) {
            try mutex.withLock { value in
                value = "changed"
                throw TestError.boom
            }
        }
        
        let current = mutex.withLock { $0 }
        #expect(current == "changed")
    }

    @Test("Test Mutex.withLockIfAvailable unlocks when body throws")
    func mutexWithLockIfAvailableThrows() {
        let mutex = Mutex("hi")

        #expect(throws: TestError.boom) {
            try mutex.withLockIfAvailable { value in
                value = "changed"
                throw TestError.boom
            }
        }
        
        let current = mutex.withLockIfAvailable { $0 }
        #expect(current == "changed")
    }
    
    @Test("Test withLockIfAvailable returns nil when locked (including throwing closure)")
    func mutexWithLockIfAvailableContended() async {
        let mutex = Mutex("hi")

        await withCheckedContinuation { lockedContinuation in
            DispatchQueue.global().async {
                mutex.withLock { _ in
                    lockedContinuation.resume()
                    Thread.sleep(forTimeInterval: 0.05)
                }
            }
        }

        let nonThrowingResult = mutex.withLockIfAvailable { _ in "acquired" }
        #expect(nonThrowingResult == nil)

        let throwingResult: String? = try? mutex.withLockIfAvailable { _ in
            throw TestError.boom
        }
        #expect(throwingResult == nil)
    }
}
