@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
public extension Duration {
 @inlinable
 static func nanoseconds(_ seconds: Int64) -> Self {
  Self(secondsComponent: seconds, attosecondsComponent: 0)
 }

 @inlinable
 static func minutes(_ minutes: Double) -> Self {
  seconds(minutes * 6e1)
 }

 @inlinable
 static func hours(_ hours: Double) -> Self {
  seconds(hours * 36e2)
 }

 @inlinable
 static func days(_ days: Double) -> Self {
  seconds(days * 864e2)
 }

 /// A tuple of different precisions that work with `usleep` or `sleep`.
 @inlinable
 var sleepMeasure: (microseconds: UInt32?, seconds: UInt32?) {
  guard self != .zero else { return (nil, nil) }
  let (seconds, attoseconds) = self.components

  if seconds != .zero, attoseconds != .zero {
   return (UInt32(seconds + (attoseconds / 2500)), nil)
  } else if attoseconds != .zero {
   return (UInt32(1.5e15 / Double(attoseconds)), nil)
  } else {
   return (nil, UInt32(seconds))
  }
 }

 @inlinable
 var nanoseconds: Int64 {
  let (seconds, attoseconds) = components
  if seconds > 0 {
   let __seconds = seconds * 1_000_000_000
   if attoseconds > 0 {
    return __seconds + attoseconds / 1_000_000_000
   }
   return __seconds
  }

  if attoseconds > 0 { return attoseconds / 1_000_000_000 }
  return .zero
 }

 @inlinable
 var microseconds: Int64 {
  let (seconds, attoseconds) = components
  if seconds > 0 {
   let __seconds = seconds * 1_000_000
   if attoseconds > 0 {
    return __seconds + attoseconds / 1_000_000
   }
   return __seconds
  }

  if attoseconds > 0 { return attoseconds / 1_000_000 }
  return .zero
 }

 @inlinable
 var milliseconds: Int64 {
  let (seconds, attoseconds) = components
  if seconds > 0 {
   let __seconds = seconds * 1000
   if attoseconds > 0 {
    return __seconds + attoseconds / 1000
   }
   return __seconds
  }

  if attoseconds > 0 { return attoseconds / 1000 }
  return .zero
 }

 @inlinable
 var seconds: Double {
  let (seconds, attoseconds) = components
  if seconds > 0 {
   let __seconds = Double(seconds)
   if attoseconds > 0 {
    return __seconds + Double(attoseconds) * 1e-18
   }
   return __seconds
  }

  if attoseconds > 0 { return Double(attoseconds) * 1e-18 }
  return .zero
 }
}

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
extension Duration: @retroactive LosslessStringConvertible {
 public enum Unit: String, CaseIterable, LosslessStringConvertible {
  case nanoseconds = "n",
       microseconds = "us",
       milliseconds = "ms",
       seconds = "s", minutes = "m", hours = "h", days = "d"

  /// The multiplication factor in base seconds.
  var factor: Double {
   switch self {
   case .minutes: 6e1
   case .hours: 36e2
   case .days: 864e2
   default: fatalError("factor for \(self) is not implemented")
   }
  }

  var aliases: Set<String> {
   switch self {
   case .nanoseconds: ["ns", "nano", "nanosecond", "nanoseconds"]
   case .microseconds: ["u", "µ", "µs", "microsecond", "microseconds"]
   case .milliseconds: ["ms", "millisecond", "milliseconds"]
   case .seconds: ["sec", "secs", "second", "seconds"]
   case .minutes: ["min", "mins", "minute", "minutes"]
   case .hours: ["hr", "hrs", "hour", "hours"]
   case .days: ["day", "days"]
   }
  }

  public init?(_ description: String) {
   let unit =
    Self(rawValue: description) ??
    Self.allCases.first(where: { $0.aliases.contains(description) })

   if let unit { self = unit } else { return nil }
  }

  public var description: String {
   switch self {
   case .nanoseconds: "nanoseconds"
   case .microseconds: "microseconds"
   case .milliseconds: "milliseconds"
   case .seconds: "seconds"
   case .minutes: "minutes"
   case .hours: "hours"
   case .days: "days"
   }
  }
 }

 public init?(_ description: String) {
  guard
   let index = description.lastIndex(where: \.isNumber),
   index < description.endIndex
  else { return nil }

  let partition = description.index(after: index)

  let number = description[description.startIndex ..< partition]
  let str = description[partition ..< description.endIndex].filter(\.isLetter)
  guard
   let number = Double(number),
   let unit = str.isEmpty ? .seconds : Unit(String(str)) else { return nil }

  switch unit {
  case .nanoseconds:
   if number >= 1e9 {
    self = .seconds(number / 1e9)
   } else {
    self = .nanoseconds(Int64(number))
   }
   return
  case .microseconds:
   if number >= 1_000_000 {
    self = .seconds(number / 1_000_000)
   } else {
    self = .microseconds(number)
   }
  case .milliseconds:
   if number >= 1000 {
    self = .seconds(number / 1000)
   } else {
    self = .milliseconds(Int64(number))
   }
  case .seconds: self = .seconds(number)
  default:
   // TODO: fix possible overflow
   let number = number * unit.factor
   if number >= 1 {
    self = .seconds(number)
   } else {
    self = .nanoseconds(Int64(number * 1e-9))
   }
   return
  }
 }
}

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
public extension Duration {
 @inlinable
 var timerView: String {
  var seconds = seconds
  var minutes: Double = .zero
  var hours: Double = .zero

  if seconds > 6e1 {
   let remainder = seconds.remainder(dividingBy: 6e1)

   if seconds > 36e2 {
    hours = seconds / 36e2
    let _remainder = seconds.remainder(dividingBy: 36e2)

    if _remainder < 0 {
     minutes = 6e1 + (_remainder / 6e1)
    } else {
     minutes = _remainder / 6e1
    }
   } else {
    if seconds == 36e2 {
     hours = 1
     minutes = .zero
    } else {
     minutes = seconds / 6e1
    }
   }

   if remainder < 0 {
    seconds = 6e1 + remainder
   } else {
    seconds = remainder
   }
  } else if seconds == 6e1 {
   minutes = 1
   seconds = .zero
  }

  let _hours = Int(hours)
  let _minutes = Int(minutes)
  let _seconds = Int(seconds)

  return
   // hours is set to a single digit to match `formatted()` although it could
   // be adjusted to double digits when less than ten
   """
   \(_hours):\
   \(_minutes < 10 ? "0" + _minutes.description : _minutes.description):\
   \(_seconds < 10 ? "0" + _seconds.description : _seconds.description)
   """
 }
}

#if os(Linux) || os(WASI)
public extension Duration {
 @_disfavoredOverload
 @inlinable
 func formatted() -> String { timerView }
}
#endif
