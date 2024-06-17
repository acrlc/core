// MARK: - Untyped KeyValueStorage
public struct AnyKeyValueStorage {
 var _keys: [Int] = .empty
 var _keysOffset: Int = .zero
 var _offsets: [Int] = .empty
 var _values: [Any] = .empty
 var _valuesOffset: Int = .zero

 public init() {}

 // MARK: Subscript Operations
 @inline(__always)
 public subscript<A>(unchecked key: Int, as type: A.Type) -> A {
  get {
   _values[uncheckedOffset(for: key)] as! A
  }
  set {
   updateValue(newValue, for: key)
  }
 }

 @inline(__always)
 public subscript<A>(key: Int, as type: A.Type) -> A? {
  get {
   guard !_keys.isEmpty else { return nil }
   var offset = 0
   while offset < _keysOffset {
    guard _keys[offset] == key else {
     offset += 1
     continue
    }
    return _values[offset] as? A
   }
   return nil
  }
  set {
   guard contains(key) else {
    store(newValue, for: key)
    return
   }
   updateValue(newValue, for: key)
  }
 }

 // MARK: Key Operations
 @inline(__always)
 @discardableResult
 public mutating func store(_ value: some Any, for key: Int) -> Int {
  let oldOffset = _valuesOffset
  let newOffset = oldOffset + 1
  let keysOffset = _keysOffset
  let newKeysOffset = keysOffset + 1

  _values.append(value)
  _valuesOffset = newOffset
  _keys.append(key)
  _keysOffset = newKeysOffset
  _offsets.append(oldOffset)
  return keysOffset
 }

 @inline(__always)
 public mutating func updateValue(_ newValue: some Any, for key: Int) {
  _values[uncheckedOffset(for: key)] = newValue
 }

 @inline(__always)
 public mutating func removeValue(for key: Int) {
  guard !_keys.isEmpty else { return }
  var offset = 0
  while offset < _keysOffset {
   guard _keys[offset] == key else {
    offset += 1
    continue
   }
   _keys.remove(at: offset)
   _keysOffset -= 1
   _offsets.remove(at: offset)
   _values.remove(at: offset)
   _valuesOffset -= 1
   return
  }
 }

 @inline(__always)
 public func contains(_ key: Int) -> Bool {
  guard !_keys.isEmpty else { return false }
  var offset = 0
  while offset < _keysOffset {
   guard _keys[offset] == key else {
    offset += 1
    continue
   }
   return true
  }
  return false
 }

 @inline(__always)
 func uncheckedOffset(for key: Int) -> Int {
  var offset = 0
  while offset < _keysOffset {
   guard _keys[offset] == key else {
    offset += 1
    continue
   }
   return _offsets[offset]
  }
  fatalError("No value was stored for key: '\(key)'")
 }

 @inline(__always)
 public func offset(for key: Int) -> Int? {
  var offset = 0
  while offset < _keysOffset {
   guard _keys[offset] == key else {
    offset += 1
    continue
   }
   return _offsets[offset]
  }
  return nil
 }
}

// MARK: Unkeyed Operations
public extension AnyKeyValueStorage {
 // MARK: Sequence Properties
 static var empty: Self { Self() }
 @inline(__always)
 var isEmpty: Bool {
  _valuesOffset == .zero
 }

 @inline(__always)
 var notEmpty: Bool {
  _valuesOffset > .zero
 }

 @inline(__always)
 mutating func empty() {
  _keys = .empty
  _keysOffset = .zero
  _values = .empty
  _valuesOffset = .zero
 }

 var values: [Any] { _values }
 var count: Int { _valuesOffset }

 // MARK: Sequence Operations
 @inline(__always)
 func uncheckedValue<A>(at offset: Int, as type: A.Type) -> A {
  _values[offset] as! A
 }

 @inline(__always)
 mutating func updateValue(_ newValue: some Any, at offset: Int) {
  _values[offset] = newValue
 }

 mutating func removeValue(at offset: Int) {
  _keys.remove(at: offset)
  _keysOffset -= 1
  _offsets.remove(at: offset)
  _values.remove(at: offset)
  _valuesOffset -= 1
 }
}

// MARK: - Typed KeyValueStorage
public struct KeyValueStorage<Value>: ~Copyable {
 var _keys: [Int] = .empty
 var _keysOffset: Int = .zero
 var _offsets: [Int] = .empty
 var _values: [Value] = .empty
 var _valuesOffset: Int = .zero

 public init() {}

 // MARK: Subscript Operations
 @inline(__always)
 public subscript(unchecked key: Int) -> Value {
  get {
   _values[uncheckedOffset(for: key)]
  }
  set {
   updateValue(newValue, for: key)
  }
 }

 @inline(__always)
 public subscript(key: Int) -> Value? {
  get {
   guard !_keys.isEmpty else { return nil }
   var offset = 0
   while offset < _keysOffset {
    guard _keys[offset] == key else {
     offset += 1
     continue
    }
    return _values[offset]
   }
   return nil
  }
  set {
   guard let newValue else { return }
   guard contains(key) else {
    store(newValue, for: key)
    return
   }
   updateValue(newValue, for: key)
  }
 }

 // MARK: Key Operations
 @inline(__always)
 @discardableResult
 public mutating func store(_ value: Value, for key: Int) -> Int {
  let oldOffset = _valuesOffset
  let newOffset = oldOffset + 1
  let keysOffset = _keysOffset
  let newKeysOffset = keysOffset + 1
  _values.append(value)
  _valuesOffset = newOffset
  _keys.append(key)
  _keysOffset = newKeysOffset
  _offsets.append(oldOffset)
  return keysOffset
 }

 @inline(__always)
 public mutating func updateValue(_ newValue: Value, for key: Int) {
  _values[uncheckedOffset(for: key)] = newValue
 }

 @inline(__always)
 public mutating func removeValue(for key: Int) {
  guard !_keys.isEmpty else { return }
  var offset = 0
  while offset < _keysOffset {
   guard _keys[offset] == key else {
    offset += 1
    continue
   }
   _keys.remove(at: offset)
   _keysOffset -= 1
   _offsets.remove(at: offset)
   _values.remove(at: offset)
   _valuesOffset -= 1
   return
  }
 }

 @inline(__always)
 public func contains(_ key: Int) -> Bool {
  guard !_keys.isEmpty else { return false }
  var offset = 0
  while offset < _keysOffset {
   guard _keys[offset] == key else {
    offset += 1
    continue
   }
   return true
  }
  return false
 }

 @inline(__always)
 func uncheckedOffset(for key: Int) -> Int {
  var offset = 0
  while offset < _keysOffset {
   guard _keys[offset] == key else {
    offset += 1
    continue
   }
   return _offsets[offset]
  }
  fatalError("No value was stored for key: '\(key)'")
 }
}

// MARK: Unkeyed Operations
public extension KeyValueStorage {
 // MARK: Sequence Properties
 static var empty: Self { Self() }
 @inline(__always)
 var isEmpty: Bool {
  _valuesOffset == .zero
 }

 @inline(__always)
 var notEmpty: Bool {
  _valuesOffset > .zero
 }

 var values: [Value] { _values }
 var count: Int { _valuesOffset }

 // MARK: Sequence Operations
 @inline(__always)
 func uncheckedValue(at offset: Int) -> Value {
  _values[offset]
 }

 @inline(__always)
 mutating func updateValue(_ newValue: Value, at offset: Int) {
  _values[offset] = newValue
 }

 mutating func removeValue(at offset: Int) {
  _keys.remove(at: offset)
  _keysOffset -= 1
  _offsets.remove(at: offset)
  _values.remove(at: offset)
  _valuesOffset -= 1
 }

 @inline(__always)
 mutating func empty() {
  _keys = .empty
  _keysOffset = .zero
  _values = .empty
  _valuesOffset = .zero
 }
}
