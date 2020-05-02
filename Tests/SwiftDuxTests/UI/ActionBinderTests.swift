import XCTest
import Combine
import SwiftUI
@testable import SwiftDux

final class ActionBinderTests: XCTestCase {
  var store: Store<TestState>!
  var binder: ActionBinder!
  
  override func setUp() {
    self.store = Store(state: TestState(), reducer: TestReducer())
    self.binder = ActionBinder(actionDispatcher: store)
  }
  
  func testInitialState() {
    XCTAssertEqual(store.state.name, "")
  }
  
  func testBindingState() {
    var binding = binder.bind(store.state.name) {
      TestAction.setName($0)
    }
    binding.wrappedValue = "new value"
    XCTAssertEqual(store.state.name, "new value")
  }
  
  func testBindingActionWithNoParameters() {
    let onSetName: ()->() = binder.bind { TestAction.setName("0") }
    onSetName()
    XCTAssertEqual(store.state.name, "0")
  }
  
  func testBindingActionWithParameters1() {
    let onSetName: (String)->() = binder.bind { TestAction.setName($0) }
    onSetName("1")
    XCTAssertEqual(store.state.name, "1")
  }
  
  func testBindingActionWithParameters2() {
    let onSetName: (String, Int)->() = binder.bind { TestAction.setName("\($0) \($1)") }
    onSetName("1", 2)
    XCTAssertEqual(store.state.name, "1 2")
  }
  
  func testBindingActionWithParameters3() {
    let onSetName: (String, Int, Float)->() = binder.bind { TestAction.setName("\($0) \($1) \($2)") }
    onSetName("1", 2, 3.1)
    XCTAssertEqual(store.state.name, "1 2 3.1")
  }
  
  func testBindingActionWithParameters4() {
    let onSetName: (String, Int, Float, Color)->() = binder.bind { TestAction.setName("\($0) \($1) \($2) \($3)") }
    onSetName("1", 2, 3.1, Color.red)
    XCTAssertEqual(store.state.name, "1 2 3.1 red")
  }
  
  func testBindingActionWithParameters5() {
    let onSetName: (String, Int, Float, Color, CGPoint)->() = binder.bind { TestAction.setName("\($0) \($1) \($2) \($3) \($4)") }
    onSetName("1", 2, 3.1, Color.red, CGPoint(x: 10, y: 5))
    XCTAssertEqual(store.state.name, "1 2 3.1 red (10.0, 5.0)")
  }
  
  func testBindingActionWithParameters6() {
    let onSetName: (String, Int, Float, Color, CGPoint, CGSize)->() = binder.bind { TestAction.setName("\($0) \($1) \($2) \($3) \($4) \($5)") }
    onSetName("1", 2, 3.1, Color.red, CGPoint(x: 10, y: 5), CGSize(width: 25, height: 30))
    XCTAssertEqual(store.state.name, "1 2 3.1 red (10.0, 5.0) (25.0, 30.0)")
  }
}

extension ActionBinderTests {
  
  struct TestState {
    var name: String = ""
  }
  
  enum TestAction: Action {
    case setName(String)
  }
  
  final class TestReducer: Reducer {
    func reduce(state: TestState, action: TestAction) -> TestState {
      var state = state
      switch action {
      case .setName(let name):
        state.name = name
      }
      return state
    }
  }
}
