import XCTest
import Combine
@testable import SwiftDux

final class StoreProxyTests: XCTestCase {
  
  func testAccessingState() {
    let store = configureStore()
    let proxy = store.proxy(for: AppState.self)
    XCTAssertEqual(proxy?.state.todoLists["123"]?.name, "Shopping List")
  }
  
  func testSendingAction() {
    let store = configureStore()
    let proxy = store.proxy(for: AppState.self)
    proxy?.send(TodoListsAction.addTodoList(name: "test"))
    XCTAssertEqual(proxy?.state.todoLists[1].name, "test")
  }
  
  func testProxyWithProtocol() {
    let store = configureStore()
    let proxy = store.proxy(for: TodoListStateRoot.self)
    XCTAssertNotNil(proxy)
  }
  
  static var allTests = [
    ("testAccessingState", testAccessingState),
    ("testSendingAction", testSendingAction),
  ]
}
