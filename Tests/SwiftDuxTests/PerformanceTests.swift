import XCTest
import Combine
@testable import SwiftDux

final class PerformanceTests: XCTestCase {
  
  func testOrderedStatePerformance() {
    measure {
      let store = Store(state: TestState.defaultState, reducer: TestReducer())
      for i in 0...10000 {
        store.send(TodoListAction.addTodo(toList: "123", withText: "Todo item \(i)"))
      }
      XCTAssertEqual(10004, store.state.todoLists["123"]?.todos.count)
      
      let firstMoveItem = store.state.todoLists["123"]?.todos.values[300]
      store.send(TodoListAction.moveTodos(inList: "123", from: IndexSet(300...5000), to: 8000))
      XCTAssertEqual(firstMoveItem?.id, store.state.todoLists["123"]?.todos.values[3300].id)
      
      let firstUndeletedItem = store.state.todoLists["123"]?.todos.values[3001]
      store.send(TodoListAction.removeTodos(fromList: "123", at: IndexSet(100...3000)))
      XCTAssertEqual(firstUndeletedItem?.id, store.state.todoLists["123"]?.todos.values[100].id)
      
    }
  }
  
  func testStoreUpdatePerformance() {
    let subsriberCount = 10000
    let sendCount = 100
    var updateCounts = 0
    var sinks = [AnyCancellable]()
    let store = Store(state: TestState.defaultState, reducer: TestReducer())
    
    sinks.reserveCapacity(subsriberCount)
    for _ in 1...subsriberCount {
      sinks.append(store.didChange.sink { _ in updateCounts += 1 })
    }
    
    measure {
      updateCounts = 0
      for _ in 1...sendCount {
        store.send(TodoListAction.doNothing)
      }
      XCTAssertEqual(updateCounts, subsriberCount * sendCount)
    }
  }

  static var allTests = [
    ("testOrderedStatePerformance", testOrderedStatePerformance),
  ]
}
