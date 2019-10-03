import XCTest
import Combine
import Dispatch
@testable import SwiftDux

final class ActionPlanTests: XCTestCase {
  var store: Store<TestState>!
  var sendAction: SendAction!
  var storeProxy: StoreProxy<TestState>!
  var sentActions: [TestAction] = []
  
  override func setUp() {
    store = Store(state: TestState(), reducer: TestReducer())
    sendAction = { [weak self] action in
      if let action = action as? TestAction {
        self?.sentActions.append(action)
      }
      if let action = action as? ActionPlan<TestState>, let storeProxy = self?.storeProxy {
        _ = action.run(storeProxy)
      }
    }
    storeProxy = StoreProxy(store: store, send: sendAction)
    sentActions = []
  }
  
  func assertActionsWereSent(_ expected: [TestAction]) {
    XCTAssertEqual(sentActions, expected)
  }
  
  func testEmptyActionPlan() {
    let actionPlan = ActionPlan<TestState> { _ in }
    _ = actionPlan.run(storeProxy)
    assertActionsWereSent([])
  }
  
  func testBasicActionPlan() {
    let actionPlan = ActionPlan<TestState> { $0.send(TestAction.actionA) }
    _ = actionPlan.run(storeProxy)
    assertActionsWereSent([TestAction.actionA])
  }
  
  func testActionPlanWithMultipleSends() {
    let actionPlan = ActionPlan<TestState> {
      $0.send(TestAction.actionA)
      $0.send(TestAction.actionB)
      $0.send(TestAction.actionA)
    }
    _ = actionPlan.run(storeProxy)
    assertActionsWereSent([
      TestAction.actionA,
      TestAction.actionB,
      TestAction.actionA
    ])
  }
  
  func testPublishableActionPlan() {
    let actionPlan = ActionPlan<TestState> { _ in
      Publishers.Sequence<[Action], Never>(sequence: [TestAction.actionB, TestAction.actionA])
    }
    if let publisher = actionPlan.run(storeProxy) {
      _ = publisher.sink(receiveValue: sendAction)
    }
    assertActionsWereSent([
      TestAction.actionB,
      TestAction.actionA
    ])
  }
  
  func testCancellableActionPlan() {
    let expectation = XCTestExpectation(description: "Expect one cancellation")
    expectation.expectedFulfillmentCount = 2
    
    let actionPlan = ActionPlan<TestState> { _ in
      Future<Action, Never> { promise in
        DispatchQueue.main.asyncAfter(deadline: .init(uptimeNanoseconds: 10000)) {
          promise(.success(TestAction.actionB))
        }
      }
      .handleEvents(
        receiveCompletion: { _ in expectation.fulfill() },
        receiveCancel: { expectation.fulfill() }
      )
    }
    
    let cancellables = [
      actionPlan.sendAsCancellable(sendAction),
      actionPlan.sendAsCancellable(sendAction)
    ]
    cancellables[1].cancel()
    
    wait(for: [expectation], timeout: 1.0)
    
    assertActionsWereSent([
      TestAction.actionB
    ])
  }

  static var allTests = [
    ("testBasicActionPlan", testBasicActionPlan)
  ]
}

extension ActionPlanTests {
  
  enum TestAction: Action, Equatable {
    case actionA
    case actionB
  }
  
  struct TestState: StateType {}
  
  class TestReducer: Reducer {
    func reduce(state: TestState, action: TestAction) -> TestState {
      state
    }
  }
  
}
