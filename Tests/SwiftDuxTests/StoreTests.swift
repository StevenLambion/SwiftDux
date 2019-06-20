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
  
  func testSubscribingToActionPlans() {
    let store = Store(state: TestSendingState(text: "initial text"), reducer: TestSendingReducer())
    store.send(PublishableActionPlan<TestSendingState> { _, _ in
      Publishers.Just(TestSendingAction.setText("1234")).eraseToAnyPublisher()
    })
    XCTAssertEqual(store.state.text, "1234")
  }
  
  func testSubscribingToComplexActionPlans() {
    let store = Store(state: TestSendingState(text: "initial text"), reducer: TestSendingReducer())
    store.send(PublishableActionPlan<TestSendingState> { dispatch, getState in
      return Publishers.Just<Int>(getState().value)
        .map { (value) -> Int in
          dispatch(TestSendingAction.setValue(value + 1))
          return getState().value
        }
        .map { (value) -> Int in
          dispatch(TestSendingAction.setValue(value + 1))
          return getState().value
        }
        .map { (value) -> Action? in
          TestSendingAction.setValue(value + 1)
        }.eraseToAnyPublisher()
    })
    XCTAssertEqual(store.state.value, 3)
  }

  static var allTests = [
    ("testInitialStateValue", testInitialStateValue),
    ("testSendingAction", testSendingAction),
    ("testSubscribingToActionPlans", testSubscribingToActionPlans),
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
