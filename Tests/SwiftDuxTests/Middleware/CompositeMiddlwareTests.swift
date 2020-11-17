import XCTest
import Combine
@testable import SwiftDux

final class CompositeMiddlewareTests: XCTestCase {
  
  func testCompiningMiddleware() {
    let middlewareA = MiddlewareA()
    let middlewareB = MiddlewareB()
    let store = Store<TestState>(state: TestState(), reducer: TestReducer(), middleware: middlewareA + middlewareB)
    store.send(TestAction.setTextUnmodified("123"))
    XCTAssertEqual(
      store.state.text,
      "123"
    )
    store.send(TestAction.setText("123"))
    XCTAssertEqual(
      store.state.text,
      "123AB"
    )
  }
  
  static var allTests = [
    ("testCombiningReducers", testCompiningMiddleware)
  ]
}

extension CompositeMiddlewareTests {
  
  struct TestState: Equatable {
    var text: String = ""
  }
  
  enum TestAction: Action {
    case setText(String)
    case setTextUnmodified(String)
  }
  
  final class TestReducer: Reducer {
    func reduce(state: TestState, action: TestAction) -> TestState {
      var state = state
      switch action {
      case .setText(let text):
        state.text = text
      case .setTextUnmodified(let text):
        state.text = text
      }
      return state
    }
  }
  
  final class MiddlewareA: Middleware {
    func run(store: StoreProxy<TestState>, action: Action) {
      if case .setText(let text) = action as? TestAction {
        store.next(TestAction.setText(text + "A"))
      } else {
        store.next(action)
      }
    }
  }
  
  final class MiddlewareB: Middleware {
    func run(store: StoreProxy<TestState>, action: Action) {
      if case .setText(let text) = action as? TestAction {
        store.next(TestAction.setText(text + "B"))
      } else {
        store.next(action)
      }
    }
  }
}
