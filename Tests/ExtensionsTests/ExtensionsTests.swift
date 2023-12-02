@testable import Extensions
import XCTest

final class TestTimerView: XCTestCase {
 let assert: KeyValuePairs<String, Duration> = [
  "0:00:45": .seconds(45),
  "0:01:00": .seconds(60),
  "0:03:55": .minutes(3) + .seconds(55),
  "0:07:00": .minutes(7),
  "1:00:00": .minutes(60),
  "1:01:00": .minutes(61),
  "1:00:01": .minutes(60) + .seconds(1),
  "1:13:46": .seconds(4426),
  "1:55:09": .hours(1) + .minutes(55) + .seconds(9),
  "4:00:00": .hours(4),
  "23:56:34": .hours(23) + .minutes(56) + .seconds(34),
  "23:59:49": .hours(23) + .minutes(59) + .seconds(49),
  "48:00:03": .days(2) + .seconds(3),
  "50:17:59": .hours(50) + .minutes(17) + .seconds(59),
  "95:59:02": .days(3) + .hours(23) + .minutes(59) + .seconds(2)
 ]

 lazy var durations = assert.map(\.1)

 var options: XCTMeasureOptions {
  let base = XCTMeasureOptions()
  base.iterationCount = 111
  return base
 }

 /// Test duration with the `formatted()` function
 func testDuration() {
  for (label, duration) in assert { XCTAssertEqual(label, duration.formatted()) }
  measure(options: options) {
   for duration in durations { _ = duration.formatted() }
  }
 }

 /// Test duration with the `timerView` property
 func testTimerView() {
  for (label, duration) in assert { XCTAssertEqual(label, duration.timerView) }
  measure(options: options) {
   for duration in durations { _ = duration.timerView }
  }
 }
}
