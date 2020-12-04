import XCTest
import Combine
@testable import SwiftDux

final class PerformanceTests: XCTestCase {
  
  func testOrderedStatePerformance() {
    measure {
      let store = configureStore()
      for i in 0...10000 {
        store.send(TodosAction.addTodo(toList: "123", withText: "Todo item \(i)"))
      }
      XCTAssertEqual(10004, store.state.todoLists["123"]?.todos.count)
      
      let firstMoveItem = store.state.todoLists["123"]?.todos.values[300]
      store.send(TodosAction.moveTodos(inList: "123", from: IndexSet(300...5000), to: 8000))
      XCTAssertEqual(firstMoveItem?.id, store.state.todoLists["123"]?.todos.values[3299].id)
      
      let firstUndeletedItem = store.state.todoLists["123"]?.todos.values[3001]
      store.send(TodosAction.removeTodos(fromList: "123", at: IndexSet(100...3000)))
      XCTAssertEqual(firstUndeletedItem?.id, store.state.todoLists["123"]?.todos.values[100].id)
    }
  }

  static var allTests = [
    ("testOrderedStatePerformance", testOrderedStatePerformance)
  ]
}
