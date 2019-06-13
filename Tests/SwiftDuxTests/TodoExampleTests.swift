import XCTest
import Combine
@testable import SwiftDux

final class TodoExampleTests: XCTestCase {
  
  func testInitialStateValue() {
    let store = Store(state: TestState.defaultState, reducer: TestReducer())
    XCTAssertEqual(store.state.todoLists.count, 1)
    XCTAssertEqual(store.state.todoLists["123"].todos.count, 3)
  }
  
  func testAddTodo() {
    let store = Store(state: TestState.defaultState, reducer: TestReducer())
    let name = "My new todo list"
    store.send(TodoListAction.addTodo(toList: "123", withText: "My new todo list"))
    let todoList = store.state.todoLists["123"]
    let todo = todoList.todos.filter { $0.text == name }.first!
    XCTAssertEqual(todoList.todos.values.first?.id, todo.id)
  }
  
  func testRemoveTodos() {
    let store = Store(state: TestState.defaultState, reducer: TestReducer())
    let lastTodo = store.state.todoLists["123"].todos.values.last!
    store.send(TodoListAction.removeTodos(fromList: "123", at: IndexSet([0, 1])))
    let todoList = store.state.todoLists["123"]
    let todo = todoList.todos.values.first!
    XCTAssertEqual(lastTodo.id, todo.id)
  }
  
  static var allTests = [
    ("testInitialStateValue", testInitialStateValue),
    ("testAddTodo", testAddTodo),
    ("testRemoveTodos", testRemoveTodos),
  ]
}
