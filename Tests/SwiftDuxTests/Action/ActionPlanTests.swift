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
        _ = action.run(storeProxy) {}
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
    _ = actionPlan.run(storeProxy) {}
    assertActionsWereSent([])
  }
  
  func testBasicActionPlan() {
    let actionPlan = ActionPlan<TestState> {
      $0.send(TestAction.actionA)
    }
    _ = actionPlan.run(storeProxy) {}
    assertActionsWereSent([TestAction.actionA])
  }
  
  func testActionPlanWithMultipleSends() {
    let actionPlan = ActionPlan<TestState> {
      $0.send(TestAction.actionA)
      $0.send(TestAction.actionB)
      $0.send(TestAction.actionA)
    }
    _ = actionPlan.run(storeProxy) {}
    assertActionsWereSent([
      TestAction.actionA,
      TestAction.actionB,
      TestAction.actionA
    ])
  }
  
  func testPublishableActionPlan() {
    let actionPlan = ActionPlan<TestState> { _ in
      [TestAction.actionB, TestAction.actionA].publisher
    }
    let cancellable = actionPlan.run(storeProxy) {}

    assertActionsWereSent([
      TestAction.actionB,
      TestAction.actionA
    ])
    
    cancellable?.cancel()
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
  
  func testChainedActionPlans() {
    let actionPlanA = ActionPlan<TestState> { store in
      store.send(TestAction.actionB)
    }
    let actionPlanB = ActionPlan<TestState> { store in
      store.send(TestAction.actionA)
    }
    let actionPlanC = ActionPlan<TestState> { store in
      store.send(TestAction.actionB)
    }
    let chainedActionPlan = actionPlanA.then(actionPlanB).then(actionPlanC)
    
    _ = chainedActionPlan.run(storeProxy) {}
    
    assertActionsWereSent([
      TestAction.actionB,
      TestAction.actionA,
      TestAction.actionB
    ])
  }
  
  func testChainedActionPlansWithPublisher() {
    let actionPlanA = ActionPlan<TestState> { store -> AnyPublisher<Action, Never> in
      Just(TestAction.actionB).delay(for: .milliseconds(10), scheduler: RunLoop.main).eraseToAnyPublisher()
    }
    let actionPlanB = ActionPlan<TestState> { store in
      store.send(TestAction.actionA)
    }
    let actionPlanC = ActionPlan<TestState> { store, next in
      Just(TestAction.actionB).send(to: store, receivedCompletion: next)
    }
    let expectation = XCTestExpectation(description: "Expect one cancellation")
    let chainedActionPlan = actionPlanA.then(actionPlanB).then(actionPlanC).then { 
      expectation.fulfill()
    }
    let cancellable = store.didChange.collect(3).sink { actions in
      actions.forEach {
        if let action = $0 as? TestAction {
          self.sentActions.append(action)
        }
      }
    }
    
    store.send(chainedActionPlan)
    
    wait(for: [expectation], timeout: 10.0)
    
    cancellable.cancel()
    
    assertActionsWereSent([
      TestAction.actionB,
      TestAction.actionA,
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
