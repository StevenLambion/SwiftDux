import XCTest
import Combine
@testable import SwiftDux

final class StoreActionDispatcherTests: XCTestCase {
  
  func testBasicActionDispatchingValue() {
    let store = configureStore()
    store.send(TodosAction.addTodo(toList: "123", withText: "My Todo"))
    XCTAssertEqual(store.state.todoLists["123"]?.todos.filter { $0.text == "My Todo"}.count, 1)
  }

  static var allTests = [
    ("testBasicActionDispatchingValue", testBasicActionDispatchingValue)
  ]
}
