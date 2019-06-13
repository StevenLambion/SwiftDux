import XCTest
import Combine
@testable import SwiftDux

final class PerformanceTests: XCTestCase {
  
  func testPerformance() {
    measure {
      let store = Store(state: TestState.defaultState, reducer: TestReducer())
      for i in 0...10000 {
        store.send(TodoListAction.addTodo(toList: "123", withText: "Todo item \(i)"))
      }
      let firstMoveItem = store.state.todoLists["123"].todos.values[300]
      store.send(TodoListAction.moveTodos(inList: "123", from: IndexSet(300...5000), to: 8000))
      XCTAssertEqual(firstMoveItem.id, store.state.todoLists["123"].todos.values[3299].id)
      
      let firstUndeletedItem = store.state.todoLists["123"].todos.values[3001]
      store.send(TodoListAction.removeTodos(fromList: "123", at: IndexSet(100...3000)))
      XCTAssertEqual(firstUndeletedItem.id, store.state.todoLists["123"].todos.values[100].id)
    }
  }

  static var allTests = [
    ("testPerformance", testPerformance),
  ]
}
