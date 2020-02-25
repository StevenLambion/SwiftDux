import XCTest
import Combine
import Dispatch
@testable import SwiftDux

final class ActionPlanTests: XCTestCase {
  var store: Store<TestState>!
  var sentActions: [TestAction] = []
  
  override func setUp() {
    store = Store(state: TestState(), reducer: TestReducer(), middleware:
      HandleActionMiddleware<TestState> { [weak self] store, action in
        if let action = action as? TestAction {
          self?.sentActions.append(action)
        }
        store.next(action)
      }
    )
    sentActions = []
  }
  
  func assertActionsWereSent(_ expected: [TestAction]) {
    XCTAssertEqual(sentActions, expected)
  }
  
  func testEmptyActionPlan() {
    let actionPlan = ActionPlan<TestState> { _ in }
    store.send(actionPlan)
    assertActionsWereSent([])
  }
  
  func testBasicActionPlan() {
    let actionPlan = ActionPlan<TestState> {
      $0.send(TestAction.actionA)
    }
    store.send(actionPlan)
    assertActionsWereSent([TestAction.actionA])
  }
  
  func testActionPlanWithMultipleSends() {
    let actionPlan = ActionPlan<TestState> {
      $0.send(TestAction.actionA)
      $0.send(TestAction.actionB)
      $0.send(TestAction.actionA)
    }
    store.send(actionPlan)
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
    let cancellable = store.sendAsCancellable(actionPlan)

    assertActionsWereSent([
      TestAction.actionB,
      TestAction.actionA
    ])
    
    cancellable.cancel()
  }
  
  func testCancellableActionPlan() {
    let expectation = XCTestExpectation(description: "Expect one cancellation")
    
    let actionPlan = ActionPlan<TestState> { store, completed in
      let cancellable = Just(TestAction.actionB)
        .delay(for: .seconds(300), scheduler: RunLoop.main)
        .send(to: store)
      
      return AnyCancellable { [cancellable] in
        cancellable.cancel()
        expectation.fulfill()
      }
    }
    
    let cancellable = store.sendAsCancellable(actionPlan)
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        cancellable.cancel()
        expectation.fulfill()
    }
    
    wait(for: [expectation], timeout: 5.0)
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
    
    _ = store.sendAsCancellable(chainedActionPlan)
    
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
    
    store.send(chainedActionPlan)
    
    wait(for: [expectation], timeout: 10.0)
    
    assertActionsWereSent([
      TestAction.actionB,
      TestAction.actionA,
      TestAction.actionB
    ])
  }

  static var allTests = [
    ("testBasicActionPlan", testBasicActionPlan),
    ("testBasicActionPlan", testBasicActionPlan),
    ("testActionPlanWithMultipleSends", testActionPlanWithMultipleSends),
    ("testPublishableActionPlan", testPublishableActionPlan),
    ("testChainedActionPlansWithPublisher", testChainedActionPlansWithPublisher),
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
