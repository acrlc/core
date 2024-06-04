@testable import Core
import XCTest

final class CoreTests: XCTestCase {
 func testSysteInfo() {
  let coreCount = SystemInfo.coreCount
  XCTAssertEqual(min(Int.max, coreCount), coreCount)
 }
}
