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

 #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
 var options: XCTMeasureOptions {
  let base = XCTMeasureOptions()
  base.iterationCount = 111
  return base
 }
 #endif

 /// Test duration with the `formatted()` function
 func testDuration() {
  for (label, duration) in assert {
   XCTAssertEqual(label, duration.formatted())
  }
  #if os(Linux) || os(Windows)
  measure {
   for duration in durations {
    _ = duration.formatted()
   }
  }
  #elseif os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
  measure(options: options) {
   for duration in durations {
    _ = duration.formatted()
   }
  }
  #endif
 }

 /// Test duration with the `timerView` property
 func testTimerView() {
  for (label, duration) in assert {
   XCTAssertEqual(label, duration.timerView)
  }
  #if os(Linux) || os(Windows)
  measure {
   for duration in durations {
    _ = duration.timerView
   }
  }
  #elseif os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
  measure(options: options) {
   for duration in durations {
    _ = duration.timerView
   }
  }
  #endif
 }
}

final class TestLosslessStringDuration: XCTestCase {
 let assert: KeyValuePairs<String, Duration> = [
  "1nanosecond": .nanoseconds(1),
  "1microsecond": .microseconds(1),
  "1millisecond": .milliseconds(1),
  "1second": .nanoseconds(1_000_000_000),
  "1second": .seconds(1),
  "1minute": .minutes(1),
  "1hour": .hours(1),
  "1day": .hours(24),
  "7days": .hours(24 * 7),
  "356days": .days(356)
 ]

 lazy var labels = assert.map(\.0)

 #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
 var options: XCTMeasureOptions {
  let base = XCTMeasureOptions()
  base.iterationCount = 111
  return base
 }
 #endif

 func test() throws {
  for (label, duration) in assert {
   try XCTAssertEqual(duration, XCTUnwrap(Duration(label)))
  }

  #if os(Linux) || os(Windows)
  measure {
   for label in labels {
    _ = Duration(label).unsafelyUnwrapped
   }
  }
  #elseif os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
  measure(options: options) {
   for label in labels {
    _ = Duration(label).unsafelyUnwrapped
   }
  }
  #endif
 }
}

final class TestCasing: XCTestCase {
 let assert: [String.Case: String] = [
  .type: "OneTwoThree",
  .camel: "oneTwoThree",
  .snake: "one_two_three",
  .identifier: "one.two.three",
  .kebab: "one-two-three"
 ]

 /// Test each case against each other with the `casing()` extension.
 /// This should check every predictable case, becauses the values in `assert`
 /// have to check against every value within `assert`.
 func test() {
  for (initialCase, initialString) in assert {
   for expectedCase in String.Case.allCases {
    // the stable string for the above case
    let expectedString = assert[expectedCase]!
    print(
     """
     Testing \(initialCase)Case, against \(expectedCase)Case \
     with initial string '\(initialString)' \
     and expected string '\(expectedString)'
     """
    )
    // the stable string matches the string cased from the initial
    XCTAssertEqual(initialString.casing(expectedCase), expectedString)
    // the initial string matches the string cased from the stable string
    XCTAssertEqual(expectedString.casing(initialCase), initialString)
   }
  }
 }

 // MARK: - Measure Casing
 #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
 var options: XCTMeasureOptions {
  let base = XCTMeasureOptions()
  base.iterationCount = 111
  return base
 }
 #endif

 // MARK: Casing for code
 func testCamelCaseToType() {
  #if os(Linux) || os(Windows)
  measure {
   _ = "oneTwoThree".casing(.type)
  }
  #elseif os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
  measure(options: options) {
   _ = "oneTwoThree".casing(.type)
  }
  #endif
  XCTAssertEqual("oneTwoThree".casing(.type), assert[.type]!)
 }

 func testTypeCaseToCamel() {
  #if os(Linux) || os(Windows)
  measure {
   _ = "OneTwoThree".casing(.camel)
  }
  #elseif os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
  measure(options: options) {
   _ = "OneTwoThree".casing(.camel)
  }
  #endif
  XCTAssertEqual("OneTwoThree".casing(.camel), assert[.camel]!)
 }

 func testSnakeCaseToType() {
  #if os(Linux) || os(Windows)
  measure {
   _ = "one_two_three".casing(.type)
  }
  #elseif os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
  measure(options: options) {
   _ = "one_two_three".casing(.type)
  }
  #endif
  XCTAssertEqual("one_two_three".casing(.type), assert[.type]!)
 }

 func testTypeCaseToSnake() {
  #if os(Linux) || os(Windows)
  measure {
   _ = "OneTwoThree".casing(.snake)
  }
  #elseif os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
  measure(options: options) {
   _ = "OneTwoThree".casing(.snake)
  }
  #endif
  XCTAssertEqual("OneTwoThree".casing(.snake), assert[.snake]!)
 }

 func testCamelCaseToSnake() {
  #if os(Linux) || os(Windows)
  measure {
   _ = "oneTwoThree".casing(.snake)
  }
  #elseif os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
  measure(options: options) {
   _ = "oneTwoThree".casing(.snake)
  }
  #endif
  XCTAssertEqual("oneTwoThree".casing(.snake), assert[.snake]!)
 }

 func testSnakeCaseToCamel() {
  #if os(Linux) || os(Windows)
  measure {
   _ = "one_two_three".casing(.camel)
  }
  #elseif os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
  measure(options: options) {
   _ = "one_two_three".casing(.camel)
  }
  #endif

  XCTAssertEqual("one_two_three".casing(.camel), assert[.camel]!)
 }

 // MARK: Casing for URLs
 func testSpacedLowercaseToKebab() {
  #if os(Linux) || os(Windows)
  measure {
   _ = "one two three".casing(.kebab)
  }
  #elseif os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
  measure(options: options) {
   _ = "one two three".casing(.kebab)
  }
  #endif
  XCTAssertEqual("one two three".casing(.kebab), assert[.kebab]!)
 }

 func testSpacedUppercaseToKebab() {
  #if os(Linux) || os(Windows)
  measure {
   _ = "One Two Three".casing(.kebab)
  }
  #elseif os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
  measure(options: options) {
   _ = "One Two Three".casing(.kebab)
  }
  #endif
  XCTAssertEqual("One Two Three".casing(.kebab), assert[.kebab]!)
 }
}
