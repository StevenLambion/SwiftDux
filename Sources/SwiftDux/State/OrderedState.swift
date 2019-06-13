import Foundation

fileprivate class OrderedStateStorage<Key, Value>: Codable, Equatable where Value: IdentifiableState, Key == Value.Id  {
  enum CodingKeys: String, CodingKey {
    case orderOfKeys
    case values
  }
  
  var orderOfKeys: [Key]
  
  var values: Dictionary<Key, Value>
  
  var cachedKeysByOrder: [Key: Int]?
  
  init(orderOfKeys: [Key], values: [Key: Value]) {
    self.orderOfKeys = orderOfKeys
    self.values = values
    self.cachedKeysByOrder = nil
  }
  
  static func == (lhs: OrderedStateStorage<Key, Value>, rhs: OrderedStateStorage<Key, Value>) -> Bool {
    return lhs.orderOfKeys == rhs.orderOfKeys && lhs.values == lhs.values
  }
  
  func index(ofKey key: Key) -> Int {
    if cachedKeysByOrder == nil {
      self.cachedKeysByOrder = Dictionary<Key, Int>(
        uniqueKeysWithValues: orderOfKeys.enumerated().map { (index, key) in (key, index) }
      )
    }
    return self.cachedKeysByOrder![key]!
  }
  
  func invalidateCache() {
    self.cachedKeysByOrder = nil
  }

}

public struct OrderedState<Key, Value>: StateType, MutableCollection where Value: IdentifiableState, Key == Value.Id {
  
  public typealias Index = Key
  public typealias Element = Value
  
  public typealias Iterator = Array<Value>.Iterator
  
  public var startIndex: Key {
    return storage.orderOfKeys.first!
  }
  
  public var endIndex: Key {
    return storage.orderOfKeys.last!
  }
  
  fileprivate var storage: OrderedStateStorage<Key, Value>
  
  public var values: [Value] {
    return storage.orderOfKeys.map { storage.values[$0]! }
  }
  
  public var count: Int {
    return storage.orderOfKeys.count
  }
  
  public subscript(position: Key) -> Value {
    get {
      return storage.values[position]!
    }
    set(newValue) {
      let copy = copyStorageIfNeeded()
      let alreadyExists = copy.values.index(forKey: position) != nil
      copy.values[position] = newValue
      if !alreadyExists {
        copy.orderOfKeys.append(position)
      }
      self.storage = copy
    }
  }
  
  public __consuming func makeIterator() -> IndexingIterator<Array<Value>> {
    return self.values.makeIterator()
  }
  
  public func index(after i: Key) -> Key {
    let index = storage.index(ofKey: i)
    return storage.orderOfKeys[index + 1]
  }
  
  private init(orderOfKeys: [Key], values: [Key:Value]) {
    self.storage = OrderedStateStorage(
      orderOfKeys: orderOfKeys,
      values: values
    )
  }
  
  public init(_ values: [Value]) {
    var ElementByIndex = [Key:Value](minimumCapacity: values.count)
    let orderOfKeys: [Key] = values.map {
      ElementByIndex[$0.id] = $0
      return $0.id
    }
    self.init(orderOfKeys: orderOfKeys, values: ElementByIndex)
  }
  
  public init(_ Value: Value...) {
    self.init(Value)
  }
  
  private mutating func copyStorageIfNeeded() -> OrderedStateStorage<Key, Value> {
    storage.invalidateCache()
//    guard isKnownUniquelyReferenced(&storage) else {
//      return OrderedStateStorage(orderOfKeys: storage.orderOfKeys, values: storage.values)
//    }
    return storage
  }
  
  public mutating func append(_ Value: Value) {
    self.insert(Value, at: storage.orderOfKeys.count)
  }
  
  public mutating func prepend(_ Value: Value) {
    self.insert(Value, at: 0)
  }
  
  public mutating func insert(_ Value: Value, at index: Int) {
    let copy = copyStorageIfNeeded()
    copy.orderOfKeys.insert(Value.id, at: index)
    copy.values[Value.id] = Value
    self.storage = copy
  }
  
  public mutating func insert<C>(contentsOf values: C, at index: Int) where C: Collection, C.Element == Value {
    let copy = copyStorageIfNeeded()
    let ids = values.map { Value -> Key in
      copy.values[Value.id] = Value
      return Value.id
    }
    copy.orderOfKeys.insert(contentsOf: ids, at: index)
    self.storage = copy
  }
  
  public mutating func remove(forIndex Key: Key) {
    let copy = copyStorageIfNeeded()
    if copy.values.removeValue(forKey: Key) != nil {
      copy.orderOfKeys.removeAll { $0 == Key }
    }
    self.storage = copy
  }
  
  public mutating func remove(at index: Int) {
    let copy = copyStorageIfNeeded()
    copy.values.removeValue(forKey: copy.orderOfKeys[index])
    copy.orderOfKeys.remove(at: index)
    self.storage = copy
  }
  
  public mutating func remove(at indexSet: IndexSet) {
    let copy = copyStorageIfNeeded()
    indexSet.forEach { copy.values.removeValue(forKey: copy.orderOfKeys[$0]) }
    copy.orderOfKeys.remove(at:  indexSet)
    self.storage = copy
  }
  
  public mutating func move(from indexSet: IndexSet, to index: Int) {
    let copy = copyStorageIfNeeded()
    let ids = Array(indexSet.map { copy.orderOfKeys[$0] })
    copy.orderOfKeys.remove(at: indexSet)
    copy.orderOfKeys.insert(contentsOf: ids, at: index)
    self.storage = copy
  }
  
  public mutating func sort(by operation: (Value, Value) -> Bool) {
    let copy = copyStorageIfNeeded()
    copy.orderOfKeys.sort { operation(copy.values[$0]!, copy.values[$1]!) }
    self.storage = copy
  }
  
  public func sorted(by operation: (Value, Value) -> Bool) -> Self {
    let orderOfKeys = storage.orderOfKeys.sorted { operation(storage.values[$0]!, storage.values[$1]!) }
    return OrderedState(orderOfKeys: orderOfKeys, values: storage.values)
  }
  
  public func filter(by operation: (Value) -> Bool) -> [Value] {
    return storage.orderOfKeys.compactMap { Key -> Value? in
      let Value = storage.values[Key]!
      return operation(Value) ? Value : nil
    }
  }
  
}

extension RangeReplaceableCollection where Self: MutableCollection, Index == Int {
  
  // Nifty optimization from user vadian at: https://stackoverflow.com/a/50835467
  
  public mutating func remove(at indexes: IndexSet) {
    guard var i = indexes.first, i < count else { return }
    var j = index(after: i)
    var k = indexes.integerGreaterThan(i) ?? endIndex
    while j != endIndex {
      if k != j { swapAt(i, j); formIndex(after: &i) }
      else { k = indexes.integerGreaterThan(k) ?? endIndex }
      formIndex(after: &j)
    }
    removeSubrange(i...)
  }
}

extension OrderedState: Equatable {
  
  public static func == (lhs: OrderedState<Key, Value>, rhs: OrderedState<Key, Value>) -> Bool {
    return lhs.storage == rhs.storage
  }
  
}

extension OrderedState {
  
  
}
