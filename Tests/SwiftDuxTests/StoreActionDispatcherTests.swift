import XCTest
import Combine
@testable import SwiftDux

final class StoreActionDispatcherTests: XCTestCase {
  
  func testBasicActionDispatchingValue() {
    let store = configureStore()
    let dispatch = store.proxy()
    dispatch(TodosAction.addTodo(toList: "123", withText: "My Todo"))
    XCTAssertEqual(store.state.todoLists["123"]?.todos.filter { $0.text == "My Todo"}.count, 1)
  }

  static var allTests = [
    ("testBasicActionDispatchingValue", testBasicActionDispatchingValue)
  ]
}
