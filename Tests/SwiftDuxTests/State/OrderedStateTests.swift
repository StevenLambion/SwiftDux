import XCTest
import Combine
import Dispatch
@testable import SwiftDux

final class OrderedStateTests: XCTestCase {
  let bob = User(id: "2", name: "Bob")
  let bill = User(id: "3", name: "Bill")
  let john = User(id: "1", name: "John")
  
  override func setUp() {
  }
  
  func testInitializeWithArray() {
    let state = OrderedState([bob, bill, john])
    XCTAssertEqual(state.values, [bob, bill, john])
  }
  
  func testInitializeWithVariadicArguments() {
    let state = OrderedState(bob, bill, john)
    XCTAssertEqual(state.values, [bob, bill, john])
  }
  
  func testInitializeFromDecoder() {
    let json = #"[{ "id": "1", "name": "John" }, { "id": "2", "name": "Bob" }, { "id": "3", "name": "Bill" }]"#
    let data = json.data(using: .utf8)!
    let decoder = JSONDecoder()
    let state = try! decoder.decode(OrderedState<User>.self, from: data);
    XCTAssertEqual(state.values, [john, bob, bill])
  }
  
  func testEncode() {
    let encoder = JSONEncoder()
    let state = OrderedState(john, bob, bill)
    let json = try! encoder.encode(state)
    XCTAssertEqual(
      String(decoding: json, as: UTF8.self),
      #"[{"id":"1","name":"John"},{"id":"2","name":"Bob"},{"id":"3","name":"Bill"}]"#
    )
  }
  
  func testAppendNewItem() {
    var state = OrderedState(bob, bill)
    state.append(john)
    XCTAssertEqual(state.values, [bob, bill, john])
  }
  
  func testAppendExistingItem() {
    var state = OrderedState(bob, john, bill)
    state.append(john)
    XCTAssertEqual(state.values, [bob, bill, john])
  }
  
  func testPrepend() {
    var state = OrderedState(bob, bill)
    state.prepend(john)
    XCTAssertEqual(state.values, [john, bob, bill])
  }
  
  func testInsertNewItem() {
    var state = OrderedState(bob, bill)
    state.insert(john, at: 1)
    XCTAssertEqual(state.values, [bob, john, bill])
  }
  
  func testInsertExistingItem() {
    var state = OrderedState(bob, bill, john)
    state.insert(john, at: 1)
    XCTAssertEqual(state.values, [bob, john, bill])
  }
  
  func testRemove() {
    var state = OrderedState(bob, bill, john)
    state.remove(at: 1)
    XCTAssertEqual(state.values, [bob, john])
  }
  
  func testRemoveIndexSet() {
    var state = OrderedState(bob, bill, john)
    state.remove(at: IndexSet([0,2]))
    XCTAssertEqual(state.values, [bill])
  }
  
  func testMoveOneUserFoward() {
    var state = OrderedState(bob, bill, john)
    state.move(from: IndexSet([1]), to: 3)
    XCTAssertEqual(state.values, [bob, john, bill])
  }
  
  func testMoveOneUserBackwards() {
    var state = OrderedState(bob, bill, john)
    state.move(from: IndexSet([2]), to: 0)
    XCTAssertEqual(state.values, [john, bob, bill])
  }
  
  func testMoveTwoUsersFoward() {
    var state = OrderedState(bob, bill, john)
    state.move(from: IndexSet([0,1]), to: 3)
    XCTAssertEqual(state.values, [john, bob, bill])
  }
  
  func testMoveTwoUsersBackwards() {
    var state = OrderedState(bob, bill, john)
    state.move(from: IndexSet([1,2]), to: 0)
    XCTAssertEqual(state.values, [bill, john, bob])
  }
  
  func testMoveAllUsers() {
    var state = OrderedState(bob, bill, john)
    state.move(from: IndexSet([0,1, 2]), to: 2)
    XCTAssertEqual(state.values, [bob, bill, john])
  }
  
  func testSort() {
    var state = OrderedState(john, bob, bill)
    state.sort { $0.name < $1.name }
    XCTAssertEqual(state.values, [bill, bob, john])
  }
  
  func testSorted() {
    let state = OrderedState(john, bob, bill).sorted { $0.name < $1.name }
    XCTAssertEqual(state.values, [bill, bob, john])
  }
  
  func testFilter() {
    let results = OrderedState(john, bob, bill).filter { $0.name == "Bob" }
    XCTAssertEqual(results, [bob])
  }
  
  func testIndexSubscript() {
    let state = OrderedState(john, bob, bill).sorted { $0.name < $1.name }
    XCTAssertEqual(state[2], john)
  }
  
  func testIdSubscript() {
    let state = OrderedState(john, bob, bill).sorted { $0.name < $1.name }
    XCTAssertEqual(state["2"], bob)
  }
  
  func testIdSubscriptWithInteger() {
    let state = OrderedState(
      Fruit(id: 1, name: "apple"),
      Fruit(id: 2, name: "orange"),
      Fruit(id: 3, name: "banana")
    )
    XCTAssertEqual(state[2], Fruit(id: 3, name: "banana"))
    XCTAssertEqual(state.value(forId: 2), Fruit(id: 2, name: "orange"))
  }
  
  func testEquality() {
    XCTAssertNotEqual(OrderedState(bob, john, bill), OrderedState(john, bob, bill))
    XCTAssertEqual(OrderedState(john, bob, bill), OrderedState(john, bob, bill))
  }

  static var allTests = [
    ("testInitializeWithArray", testInitializeWithArray),
    ("testInitializeWithVariadicArguments", testInitializeWithVariadicArguments),
    ("testEncode", testEncode),
    ("testAppendNewItem", testAppendNewItem),
    ("testAppendExistingItem", testAppendExistingItem),
    ("testPrepend", testPrepend),
    ("testInsertNewItem", testInsertNewItem),
    ("testInsertExistingItem", testInsertExistingItem),
    ("testRemove", testRemove),
    ("testRemoveIndexSet", testRemoveIndexSet),
    ("testMoveOneUserFoward", testMoveOneUserFoward),
    ("testMoveOneUserBackwards", testMoveOneUserBackwards),
    ("testMoveTwoUsersFoward", testMoveTwoUsersFoward),
    ("testMoveTwoUsersBackwards", testMoveTwoUsersBackwards),
    ("testMoveAllUsers", testMoveAllUsers),
    ("testSort", testSort),
    ("testSorted", testSorted),
    ("testFilter", testFilter),
    ("testIndexSubscript", testIndexSubscript),
    ("testIdSubscript", testIdSubscript),
    ("testIdSubscriptWithInteger", testIdSubscriptWithInteger),
    ("testEquality", testEquality),
  ]
}

extension OrderedStateTests {
  
  struct User: Identifiable, Codable, Equatable {
    var id: String
    var name: String
  }
  
  struct Fruit: Identifiable, Codable, Equatable {
    var id: Double
    var name: String
  }
}
