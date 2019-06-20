import XCTest
import Combine
@testable import SwiftDux

final class StoreActionDispatcherTests: XCTestCase {
  
  func testBasicActionDispatchingValue() {
    let store = Store(state: TestState.defaultState, reducer: TestReducer())
    let dispatcher = store.proxy()
    dispatcher.send(TodoListAction.addTodo(toList: "123", withText: "My Todo"))
    XCTAssertEqual(store.state.todoLists["123"].todos.filter { $0.text == "My Todo"}.count, 1)
  }
  
  func testModifyingActionsValue() {
    let store = Store(state: TestState.defaultState, reducer: TestReducer())
    let dispatcher = store.proxy {
      if $0 is TodoListAction {
        return TestAction.routeTodoAction(forList: "123", action: $0)
      }
      return $0
    }
    dispatcher.send(TodoListAction.addTodo2(withText: "My Todo"))
    XCTAssertEqual(store.state.todoLists["123"].todos.filter { $0.text == "My Todo"}.count, 1)
  }

  static var allTests = [
    ("testBasicActionDispatchingValue", testBasicActionDispatchingValue),
    ("testModifyingActionsValue", testModifyingActionsValue)
  ]
}
