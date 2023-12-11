@available(macOS 13, iOS 16, *)
public extension Duration {
 @inlinable static func minutes(_ minutes: Double) -> Self {
  self.seconds(minutes * 6e1)
 }

 @inlinable static func hours(_ hours: Double) -> Self {
  self.seconds(hours * 36e2)
 }

 @inlinable static func days(_ days: Double) -> Self {
  self.seconds(days * 864e2)
 }

 /// Returns an tuple containing optional the optional unsigned integer for
 /// microseconds or seconds, which is useful for functions that work with
 /// different precision such as `sleep` or `usleep`
 @inlinable var sleepMeasure: (microseconds: UInt32?, seconds: UInt32?) {
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

@available(macOS 13, iOS 16, *)
extension Duration: LosslessStringConvertible {
 public enum Unit: String, CaseIterable, LosslessStringConvertible {
  case nanoseconds = "n", 
       microseconds = "us",
       milliseconds = "ms",
       seconds = "s", minutes = "m", hours = "h", days = "d"
  /// The multiplication factor in base seconds.
  var factor: Double {
   switch self {
   case .minutes: return 6e1
   case .hours: return 36e2
   case .days: return 864e2
   default: fatalError("factor for \(self) is not implemented")
   }
  }

  var aliases: Set<String> {
   switch self {
   case .nanoseconds: return ["ns", "nano", "nanosecond", "nanoseconds"]
   case .microseconds: return ["u", "µ", "µs", "microseconds", "microseconds"]
   case .milliseconds: return ["ms", "millisecond", "milliseconds"]
   case .seconds: return ["sec", "secs", "second", "seconds"]
   case .minutes: return ["min", "mins", "minute", "minutes"]
   case .hours: return ["hr", "hrs", "hour", "hours"]
   case .days: return ["day", "days"]
   }
  }

  public init?(_ description: String) {
   let unit = Self(rawValue: description) ??
    Self.allCases.first(where: { $0.aliases.contains(description) })
   if let unit { self = unit }
   else { return nil }
  }

  public var description: String {
   switch self {
   case .nanoseconds: return "nanoseconds"
   case .microseconds: return "microseconds"
   case .milliseconds: return "milliseconds"
   case .seconds: return "seconds"
   case .minutes: return "minutes"
   case .hours: return "hours"
   case .days: return "days"
   }
  }
 }

 public init?(_ description: String) {
  guard let index = description.lastIndex(where: \.isNumber),
        index < description.endIndex
  else { return nil }

  let partition = description.index(after: index)

  let number = description[description.startIndex ..< partition]
  let str = description[partition ..< description.endIndex].filter(\.isLetter)
  guard let number = Double(number),
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
    // TODO: fix fractions causing long numbers
    // must be manually separated from the seconds component?
    self = .seconds(number)
   } else {
    self = .nanoseconds(Int64(number * 1e-9))
   }
   return
  }
 }
}

@available(macOS 13, iOS 16, *)
public extension Duration {
 @inlinable var timerView: String {
  var seconds = self.seconds
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

#if os(Linux)
public extension Duration {
 @_disfavoredOverload
 @inlinable func formatted() -> String { timerView }
}
#endif
