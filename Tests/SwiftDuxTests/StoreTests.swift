import XCTest
import Combine
@testable import SwiftDux

final class StoreTests: XCTestCase {
  var store: Store<TestSendingState>!
  
  override func setUp() {
    store = Store(state: TestSendingState(text: "initial text"), reducer: TestSendingReducer())
  }
  
  override func tearDown() {
    store = nil
  }
  
  func testInitialStateValue() {
    XCTAssertEqual(store.state.text, "initial text")
  }
  
  func testSendingAction() {
    store.send(TestSendingAction.setText("New text"))
    XCTAssertEqual(store.state.text, "New text")
  }
  
  func testActionPlans() {
    store.send(ActionPlan<TestSendingState> { store, next in
      Just(TestSendingAction.setText("1234")).send(to: store, receivedCompletion: next)
    })
    XCTAssertEqual(store.state.text, "1234")
  }
  
  func testSubscribingToActionPlans() {
    store.send(ActionPlan<TestSendingState> { store in
      Just<Action>(TestSendingAction.setText("1234"))
    })
    XCTAssertEqual(store.state.text, "1234")
  }
  
  func testSubscribingToComplexActionPlans() {
    store.send(ActionPlan<TestSendingState> { store in
      Just<Int>(store.state.value)
        .map { value -> Int in
          store.send(TestSendingAction.setValue(value + 1))
          return store.state.value
        }
        .map { value -> Int in
          store.send(TestSendingAction.setValue(value + 1))
          return store.state.value
        }
        .map { value -> Action in
          TestSendingAction.setValue(value + 1)
        }
    })
    XCTAssertEqual(store.state.value, 3)
  }

  func testStoreCleansUpSubscriptions() {
    let expectation = XCTestExpectation(description: "Expect cancellation")
    var cancellables = Set<AnyCancellable>()
    
    expectation.expectedFulfillmentCount = 6
    
    let actionPlan = ActionPlan<TestSendingState> { store, completed in
      let cancellable = Just(TestSendingAction.setText("test"))
        .delay(for: .milliseconds(10), scheduler: RunLoop.main)
        .send(to: store, receivedCompletion: completed)
      
      cancellable.store(in: &cancellables)
      
      // Make sure there's only one cancellable at a time to validate
      // the action plans are running synchronously and not leaving
      // cancellables around.
      return AnyCancellable {
        XCTAssertEqual(cancellables.count, 1)
        cancellables.remove(cancellable)
        expectation.fulfill()
      }
    }
    
    let groupedPlans = actionPlan
      .then(actionPlan)
      .then(actionPlan)
      .then(actionPlan)
      .then(actionPlan)
      .then(actionPlan)
    
    store.send(groupedPlans)
    
    wait(for: [expectation], timeout: 1.0)
    XCTAssertEqual(cancellables.count, 0)
  }
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
