import Foundation

fileprivate struct IgnoredDecodedState: Codable {}

/// Storage for the ordered state to decrease the copying of the internal data structures.
@usableFromInline
internal class OrderedStateStorage<Substate> where Substate: Identifiable {
  enum CodingKeys: String, CodingKey {
    case orderOfIds
    case values
  }

  /// The id type used by the substates.
  public typealias ID = Substate.ID

  /// Holds the oredering knowledge of the values by their key.
  public var orderOfIds: [ID]

  /// Holds the actual value referenced by its key.
  public var values: [ID: Substate]

  /// For the usage of ordered enumerations, this property caches a reverse lookup table from key to ordered position.
  public var cachedIdsByOrder: [ID: Int]?

  /// Sets the initial values and their ordered positions.
  ///
  /// This class assumes that the data in both `orderOfIds` and `values` are perfectly synced.
  /// - Parameters
  ///   - orderOfIds: The ids of each substate in a specific order.
  ///   - values: A lookup table of substates by their ids.
  @inlinable init(orderOfIds: [ID], values: [ID: Substate]) {
    self.orderOfIds = orderOfIds
    self.values = values
    self.cachedIdsByOrder = nil
  }

  /// Returns the ordered index position of a key.
  ///
  /// This method assumes it will be called multiple times in succession, so it internally caches
  /// the indexes by their keys in a reverse lookup table.
  ///
  /// - Parameter id: The key to look  up its ordered index position.
  /// - Returns: The ordered index that corrosponds to an id.
  @inlinable func index(ofId id: ID) -> Int {
    if cachedIdsByOrder == nil {
      self.cachedIdsByOrder = [ID: Int](
        uniqueKeysWithValues: orderOfIds.enumerated().map { (index, id) in (id, index) }
      )
    }
    return self.cachedIdsByOrder![id]!
  }

  /// Invalidates the caches. This should be called when it's assumed that the order of keys may change.
  @inlinable func invalidateCache() {
    self.cachedIdsByOrder = nil
  }
}

extension OrderedStateStorage: Equatable where Substate: Equatable {

  @inlinable static func == (lhs: OrderedStateStorage<Substate>, rhs: OrderedStateStorage<Substate>) -> Bool {
    lhs.orderOfIds == rhs.orderOfIds && lhs.values == rhs.values
  }
}

/// A container state that holds an ordered collection of substates.
///
/// It's a common requirement to store a collection of substates. For example, a list of entities retrieved from a service.
/// For an optimal solution, you typically require a lookup table of entity states by their ids. However, you also need an ordered array
/// to display those entities in a list to the user. You end up managing both a dictionary of entities and an ordered array of their ids.
/// This struct manages that responsibility for you. It also provides conveniences for direct use by SwiftUI `List` views.
///
/// ```
/// var todos: OrderedState<TodoState> = ...
///
/// // When a user adds a new todo:
/// todos.append(todo)
///
/// // When a user deletes multiple todos
/// todos.delete(at: indexSet)
///
/// // Using the OrderedState with a list view.
/// var body: some View {
///   List {
///     ForEach(todos) {
///     }
///     .onDelete { todos.delete(at: $0 }
///     .onMove { todos.move(from: $0, to: $1 }
///   }
/// }
///
/// ```
public struct OrderedState<Substate> where Substate: Identifiable {

  public typealias Id = Substate.ID
  public typealias Index = Int

  @usableFromInline
  internal var storage: OrderedStateStorage<Substate>

  /// The substates as an ordered array
  @inlinable public var values: [Substate] {
    storage.orderOfIds.map { storage.values[$0]! }
  }

  /// The number of substates
  @inlinable public var count: Int {
    storage.orderOfIds.count
  }

  /// Used for internal copy operations.
  ///
  /// - Parameters
  ///   - orderOfIds: The ids of each substate in a specific order.
  ///   - values: A lookup table of substates by their ids.
  @inlinable internal init(orderOfIds: [Id], values: [Id: Substate]) {
    self.storage = OrderedStateStorage(
      orderOfIds: orderOfIds,
      values: values
    )
  }

  /// Create a new `OrderedState` with an ordered array of identifiable substates.
  ///
  /// - Parameter values: An array of substates. The position of each substate will be used as the initial order.
  @inlinable public init(_ values: [Substate]) {
    var valueByIndex = [Id: Substate](minimumCapacity: values.count)
    let orderOfIds: [Id] = values.map {
      valueByIndex[$0.id] = $0
      return $0.id
    }

    self.init(orderOfIds: orderOfIds, values: valueByIndex)
  }

  /// Create a new `OrderedState` with a variadic number of substates.
  /// - Parameter value: A variadic list of substates. The position of each substate will be used as the initial order.
  @inlinable public init(_ value: Substate...) {
    self.init(value)
  }

  /// Used internally to copy the storage for mutating operations.
  ///
  /// It's designed not to copy if it's singularily owned by a single copy of the `OrderedState` struct.
  /// This method is expected to be used only by mutating methods, so it also invalidates any caching
  /// inside the storage object.
  /// - Returns: The original storage if it is referenced only once, or a new copy.
  @inlinable internal mutating func copyStorageIfNeeded() -> OrderedStateStorage<Substate> {
    guard isKnownUniquelyReferenced(&storage) else {
      return OrderedStateStorage(orderOfIds: storage.orderOfIds, values: storage.values)
    }

    storage.invalidateCache()
    return storage
  }

  /// Retrieves a value by its id.
  ///
  /// The subscript API should be used in most cases. This method is
  /// provided in case the Substate's id type is also an int.
  /// - Parameter id: The id of the substate.
  /// - Returns: The substate if it exists.
  @inlinable public func value(forId id: Id) -> Substate? {
    storage.values[id]
  }

  /// Append a new substate to the end of the `OrderedState`.
  ///
  /// - Parameter value: A new substate to append to the end of the list.
  @inlinable public mutating func append(_ value: Substate) {
    self.remove(forId: value.id)  // Remove if it already exists.

    let copy = copyStorageIfNeeded()

    copy.orderOfIds.append(value.id)
    copy.values[value.id] = value
    self.storage = copy
  }

  /// Prepend a new substate to the beginning of the `OrderedState`.
  ///
  /// - Parameter value: A new substate to append to the beginning of the list.
  @inlinable public mutating func prepend(_ value: Substate) {
    self.insert(value, at: 0)
  }

  /// Inserts a new substate at the given index `OrderedState`.
  ///
  /// - Parameters
  ///   - value: A new substate to insert at a specific position in the list
  ///   - index: The index of the inserted substate. This will adjust the overall order of the list.
  @inlinable public mutating func insert(_ value: Substate, at index: Int) {
    if let _ = storage.values[value.id], let currentIndex = storage.orderOfIds.firstIndex(of: value.id) {
      self.move(from: IndexSet(integer: currentIndex), to: index)
      let copy = copyStorageIfNeeded()
      copy.values[value.id] = value
      self.storage = copy
    } else {
      let copy = copyStorageIfNeeded()
      copy.orderOfIds.insert(value.id, at: index)
      copy.values[value.id] = value
      self.storage = copy
    }
  }

  /// Inserts a collection of substates at the given index `OrderedState`.
  ///
  /// - Parameters
  ///   - values: The new substates to insert. This must be an ordered collection for defined behavior.
  ///   - index: The index of the inserted substates. This will adjust the overall order of the list.
  @inlinable public mutating func insert<C>(contentsOf values: C, at index: Int) where C: Collection, C.Element == Substate {
    let copy = copyStorageIfNeeded()
    let ids = values.map { value -> Id in
      copy.values[value.id] = value
      return value.id
    }

    copy.orderOfIds.insert(contentsOf: ids, at: index)
    self.storage = copy
  }

  /// Removes a substate for the given id.
  ///
  /// - Parameter id: The id of the substate to remove. This will adjust the order of items.
  @inlinable public mutating func remove(forId id: Id) {
    guard storage.values[id] != nil else { return }
    let copy = copyStorageIfNeeded()

    if copy.values.removeValue(forKey: id) != nil {
      copy.orderOfIds.removeAll { $0 == id }
    }

    self.storage = copy
  }

  /// Removes a substate at a given index.
  ///
  /// - Parameter index: The index of the substate to remove. This will adjust the order of items.
  @inlinable public mutating func remove(at index: Int) {
    let copy = copyStorageIfNeeded()

    copy.values.removeValue(forKey: copy.orderOfIds[index])
    copy.orderOfIds.remove(at: index)
    self.storage = copy
  }

  /// Removes substates at the provided indexes.
  ///
  /// - Parameter indexSet: Removes all items in the provided indexSet. This will adjust the order of items.
  @inlinable public mutating func remove(at indexSet: IndexSet) {
    let copy = copyStorageIfNeeded()

    indexSet.forEach { copy.values.removeValue(forKey: copy.orderOfIds[$0]) }
    copy.orderOfIds.remove(at: indexSet)
    self.storage = copy
  }

  /// Moves a set of substates at the specified indexes to a new index position.
  ///
  /// - Parameters
  ///   - indexSet: A set of indexes to move to a new location. The order of indexes will be used as part of the new order of the moved items.
  ///   - index: The new position for the moved items.
  @inlinable public mutating func move(from indexSet: IndexSet, to index: Int) {
    guard !indexSet.contains(where: { $0 == index }) else { return }
    let copy = copyStorageIfNeeded()
    let index = Swift.max(Swift.min(index, copy.orderOfIds.count), 0)
    let ids = Array(indexSet.map { copy.orderOfIds[$0] })
    let offset = Swift.max(indexSet.reduce(0) { (result, i) in i < index ? result + 1 : result }, 0)

    copy.orderOfIds.remove(at: indexSet)
    copy.orderOfIds.insert(contentsOf: ids, at: index - offset)
    self.storage = copy
  }

  /// Resorts the order of substates with the given sort operation.
  ///
  /// - Parameter areInIncreasingOrder: Orders the items by indicating whether not the second item is bigger than the first item.
  @inlinable public mutating func sort(by areInIncreasingOrder: (Substate, Substate) -> Bool) {
    let copy = copyStorageIfNeeded()

    copy.orderOfIds.sort { areInIncreasingOrder(copy.values[$0]!, copy.values[$1]!) }
    self.storage = copy
  }

  /// Returns an `OrderedState` with the new sort order.
  ///
  /// - Parameter areInIncreasingOrder: Orders the items by indicating whether not the second item is bigger than the first item.
  /// - Returns: A new `OrderedState` with the provided sort operation.
  @inlinable public func sorted(by areInIncreasingOrder: (Substate, Substate) -> Bool) -> Self {
    OrderedState(
      orderOfIds: storage.orderOfIds.sorted { areInIncreasingOrder(storage.values[$0]!, storage.values[$1]!) },
      values: storage.values
    )
  }

  /// Filters the substates using a predicate.
  ///
  /// - Parameter isIncluded: Indicate the state should be included in the returned array.
  /// - Returns: an array of substates filtered by the provided operation.
  @inlinable public func filter(_ isIncluded: (Substate) -> Bool) -> [Substate] {
    storage.orderOfIds.compactMap { id -> Substate? in
      let value = storage.values[id]!
      return isIncluded(storage.values[id]!) ? value : nil
    }
  }
}

extension OrderedState: MutableCollection {

  /// The starting index of the collection.
  @inlinable public var startIndex: Int {
    storage.orderOfIds.startIndex
  }

  /// The last index of the collection.
  @inlinable public var endIndex: Int {
    storage.orderOfIds.endIndex
  }

  /// Subscript based on the index of the substate.
  ///
  /// - Parameter position: The index of the substate.
  /// - Returns: The substate
  @inlinable public subscript(position: Int) -> Substate {
    get {
      storage.values[storage.orderOfIds[position]]!
    }
    set(newValue) {
      self.insert(newValue, at: position)
    }
  }

  /// Subscript based on the id of the substate.
  ///
  /// - Parameter position: The id of the substate.
  /// - Returns: The substate
  @inlinable public subscript(position: Id) -> Substate? {
    get {
      value(forId: position)
    }
    set(newValue) {
      guard let newValue = newValue else { return }

      if storage.values[position] != nil {
        let copy = copyStorageIfNeeded()

        copy.values[position] = newValue
        self.storage = copy
      } else {
        self.append(newValue)
      }
    }
  }

  /// Create an ordered iterator of the substates.
  ///
  /// - Returns: The ordered iterator.
  @inlinable public __consuming func makeIterator() -> IndexingIterator<[Substate]> {
    return self.values.makeIterator()
  }

  /// Get the index of a substate after a sibling one.
  ///
  /// - Parameter i: The index of the substate directly before the target one.
  /// - Returns: The next index
  @inlinable public func index(after i: Int) -> Int {
    return storage.orderOfIds.index(after: i)
  }

  /// Get the id of a substate directly after a sibling one.
  ///
  /// - Parameter i: The id of the substate directly before the target one.
  /// - Returns: The next id
  @inlinable public func index(after i: Id) -> Id {
    let index = storage.index(ofId: i)
    return storage.orderOfIds[index + 1]
  }
}

extension OrderedState: RandomAccessCollection {}

extension RangeReplaceableCollection where Self: MutableCollection, Index == Int {

  /// From user vadian at [stackoverflows](https://stackoverflow.com/a/50835467)
  /// Walks the length of the collection using `swapAt` to move all deleted items to the end. Then it performs
  /// a single remove operation.

  /// Removes substates at the provided indexes.
  /// - Parameter indexes: Removes all items in the provided indexSet.
  @inlinable public mutating func remove(at indexes: IndexSet) {
    guard var i = indexes.first, i < count else { return }
    var j = index(after: i)
    var k = indexes.integerGreaterThan(i) ?? endIndex

    while j != endIndex {
      if k != j {
        swapAt(i, j)
        formIndex(after: &i)
      } else {
        k = indexes.integerGreaterThan(k) ?? endIndex
      }
      formIndex(after: &j)
    }

    removeSubrange(i...)
  }
}

extension OrderedState: Equatable where Substate: Equatable {

  @inlinable public static func == (lhs: OrderedState<Substate>, rhs: OrderedState<Substate>) -> Bool {
    lhs.storage == rhs.storage
  }
}

extension OrderedState: Decodable where Substate: Decodable {

  ///Decodes the `OrderState<_>` from an unkeyed container.
  ///
  /// This allows the `OrderedState<_>` to be decoded from a simple array.
  ///
  /// - Parameter decoder: The decoder.
  /// - Throws: This function throws an error if the OrderedState could not be decoded.
  public init(from decoder: Decoder) throws {
    var container = try decoder.unkeyedContainer()
    var values = [Substate]()

    while !container.isAtEnd {
      do {
        values.append(try container.decode(Substate.self))
      } catch {
        _ = try container.decode(IgnoredDecodedState.self)
      }
    }

    self.init(values)
  }

}

extension OrderedState: Encodable where Substate: Encodable {

  /// Encodes the `OrderState<_>` as an unkeyed container of values.
  ///
  /// This allows the `OrderedState<_>` to be encoded as simple array.
  ///
  /// - Parameter encoder: The encoder.
  /// - Throws: This function throws an error if the OrderedState could not be encoded.
  @inlinable public func encode(to encoder: Encoder) throws {
    var container = encoder.unkeyedContainer()
    try container.encode(contentsOf: values)
  }

}
