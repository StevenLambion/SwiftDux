import XCTest
import Combine
@testable import SwiftDux

final class StoreTests: XCTestCase {
  
  func testInitialStateValue() {
    let store = Store(state: TestSendingState(text: "initial text"), reducer: TestSendingReducer())
    XCTAssertEqual(store.state.text, "initial text")
  }
  
  func testSendingAction() {
    let store = Store(state: TestSendingState(text: "initial text"), reducer: TestSendingReducer())
    store.send(TestSendingAction.setText("New text"))
    XCTAssertEqual(store.state.text, "New text")
  }
  
  func testActionPlans() {
    let store = Store(state: TestSendingState(text: "initial text"), reducer: TestSendingReducer())
    store.send(ActionPlan<TestSendingState> { store, next in
      Just(TestSendingAction.setText("1234")).send(to: store, receivedCompletion: next)
    })
    XCTAssertEqual(store.state.text, "1234")
  }
  
  func testSubscribingToActionPlans() {
    let store = Store(state: TestSendingState(text: "initial text"), reducer: TestSendingReducer())
    store.send(ActionPlan<TestSendingState> { store in
      Just<Action>(TestSendingAction.setText("1234"))
    })
    XCTAssertEqual(store.state.text, "1234")
  }
  
  func testSubscribingToComplexActionPlans() {
    let store = Store(state: TestSendingState(text: "initial text"), reducer: TestSendingReducer())
    store.send(ActionPlan<TestSendingState> { store in
      Just<Int>(store.state?.value ?? 0)
        .map { value -> Int in
          store.send(TestSendingAction.setValue(value + 1))
          return store.state?.value ?? 0
        }
        .map { value -> Int in
          store.send(TestSendingAction.setValue(value + 1))
          return store.state?.value ?? 0
        }
        .map { value -> Action in
          TestSendingAction.setValue(value + 1)
        }
    })
    XCTAssertEqual(store.state.value, 3)
  }

  static var allTests = [
    ("testInitialStateValue", testInitialStateValue),
    ("testSendingAction", testSendingAction),
    ("testActionPlans", testActionPlans),
    ("testSubscribingToActionPlans", testSubscribingToActionPlans),
    ("testSubscribingToComplexActionPlans", testSubscribingToComplexActionPlans),
  ]
}

extension StoreTests {
  
  enum TestSendingAction: Action {
    case setText(String)
    case setValue(Int)
  }
  
  enum TestSendingIntruderAction: Action {
    case setText(String)
  }
  
  struct TestSendingState: StateType {
    var text: String
    var value: Int = 0
  }
  
  class TestSendingReducer: Reducer {
    func reduce(state: TestSendingState, action: TestSendingAction) -> TestSendingState {
      var state = state
      switch action {
      case .setText(let text):
        state.text = text
      case .setValue(let value):
        state.value = value
      }
      return state
    }
    
    func reduceNext(state: StoreTests.TestSendingState, action: Action) -> StoreTests.TestSendingState {
      var state = state
      if case TestSendingIntruderAction.setText(let text) = action {
        state.text = text
      }
      return state
    }
  }
  
}
