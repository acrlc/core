@testable import Core
import XCTest

final class TestStorage: XCTestCase {
 func testKeyValueStorage() async {
  var rawDictionaryStorage: KeyValueStorage<Int> = .empty
  for int in 0 ... 99 {
   rawDictionaryStorage.store(int, for: int)
   XCTAssertEqual(int, rawDictionaryStorage[int])
  }

  XCTAssert(rawDictionaryStorage.notEmpty)

  rawDictionaryStorage.empty()
  XCTAssert(rawDictionaryStorage.isEmpty)
 }
}
