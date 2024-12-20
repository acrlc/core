import Components
import Foundation
import XCTest

final class ComponentsTests: XCTestCase {
 let assert:
  KeyValuePairs<KeyPath<Components.Regex, String>, [(Bool, String)]> = [
   \.email: [
    "example@icloud.com",
    "person@subdomain.domain.com"
   ]
   .map { (true, $0) } + [
    "123",
    "@google.com",
    "\"kevin\"@google.com"
   ]
   .map { (false, $0) },
   \.url: [
    "google.com",
    "https://www.apple.com"
   ]
   .map { (true, $0) } + [
    "123",
    "123/abc",
    "okay@google"
   ]
   .map { (false, $0) }
  ]

 func testRegex() {
  for (keyPath, assertionPairs) in assert {
   let regex = String.regex[keyPath: keyPath]
   for assertionPair in assertionPairs {
    let assertion = assertionPair.0
    let string = assertionPair.1
    let range = string.range(
     of: regex, options: [.regularExpression]
    )
    let matchRange = range ?? string.startIndex ..< string.startIndex
    let output = String(string[matchRange])
    XCTAssertEqual(assertion ? string : String(), output)
   }
  }
 }
}
