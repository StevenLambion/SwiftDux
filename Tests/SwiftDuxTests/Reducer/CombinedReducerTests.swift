import XCTest
import Combine
@testable import SwiftDux

final class CombinedReducerTests: XCTestCase {
  
  func testCombiningReducers() {
    let reducer = ReducerA() + ReducerB()
    XCTAssertEqual(
      reducer.reduceAny(state: TestState(), action: TestAction.setStateA("123")),
      TestState(stateA: "123")
    )
    XCTAssertEqual(
      reducer.reduceAny(state: TestState(), action: TestAction.setStateB("321")),
      TestState(stateB: "321")
    )
  }
  
  static var allTests = [
    ("testCombiningReducers", testCombiningReducers)
  ]
}

extension CombinedReducerTests {
  
  struct TestState: Equatable {
    var stateA: String = ""
    var stateB: String = ""
  }
  
  enum TestAction: Action {
    case setStateA(String)
    case setStateB(String)
  }
  
  final class ReducerA: Reducer {
    func reduce(state: TestState, action: TestAction) -> TestState {
      var state = state
      switch action {
      case .setStateA(let stateA):
        state.stateA = stateA
      default:
        break;
      }
      return state
    }
  }
  
  final class ReducerB: Reducer {
    func reduce(state: TestState, action: TestAction) -> TestState {
      var state = state
      switch action {
      case .setStateB(let stateB):
        state.stateB = stateB
      default:
        break;
      }
      return state
    }
  }
}
