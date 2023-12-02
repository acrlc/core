## Core
### Protocols
#### `AutoCodable` aka `AutoEncodable` and `AutoDecodable` 
A protocol for initializing and storing known data types

An object that conforms to `AutoCodable` or the in practice protocol `JSONCodable`
```swift
struct Value: AutoCodable {
 static let encoder = JSONEncoder()
 static let decoder = JSONDecoder()
}
// or conform to an autocodable protocol if the value is codable
extension Value: JSONCodable {}

// auto encode and decode JSON formatted values
let value = Value()
let data = value.data
let decoded = try Value(data)
```
#### `Infallible`
This is a protocol that allows values to be unwrapped through inference by declaring the static property `defaultValue` 
### Expressible Protocols
#### `ExpressibleAsEmpty`
Allows the static property `empty`, local property `isEmpty`/`notEmpty` to be declared and `wrapped` into an optional that is `nil` when empty
#### `ExpressibleAsZero`
Allows a value to be expressed using the static property `zero`
#### `ExpressibleAsStart`
Allows a value to be expressed using the static property `start`
### Structures
#### `RecursiveNode`
A recursive structure that stores the current position of a node, relative to a starting node. This value doesn’t store elements (or itself), it points to a set of arrays `[[Self]]` and `[[Value]]` so they can be stored recursively and separately from the higher level, which is great for reflection and creating recursive values that would have problems in arrays or structs and may need to indicate some form of hiearchical or graph like structure. As more testing is done, there will be more examples and documentation.

## Extensions
Extended functionality for common types such as `Duration`, `String`, and `Optional`, core types such as, `Infallible` and `Randomizable`, and a couple of convenience functions.

A way to unwrap many values or simplify testing
```swift
try some.throwing()
try optional.throwing(Error.notFound)
```
A randomized `Date` within a certain range
```swift
let date = Date.random // minute to 27 days past
let random = Date.random(60 ..< 86400) // minute to a day
```
Delayed async task and sleep using the public namespace
```swift
try await withTask(after: 1e9) { ... } 
try await sleep(for: .seconds(1))
```

## Components
Common names and expressions
### Expressions
#### `Regex`
The default namespace for common regular expressions that can be accessed from a `String` and used as parameters
```swift
let keyPath: KeyPath<Regex, String> = \.url
let expression = String.regex[keyPath: keyPath] // the expanded pattern
```
### Context
#### `Subject`
A string that represents any group of objects such as `error` or `info`
```swift
extension Subject {
 static let debug: Self = "debug"
}
let subject = Subject.debug
```
#### `Descriptor`
A string, such as `optional` or `nil` that describes a subject or object
```swift
extension Descriptor {
 static let final: Self = "final"
}
let descriptor = Descriptor.final
```

