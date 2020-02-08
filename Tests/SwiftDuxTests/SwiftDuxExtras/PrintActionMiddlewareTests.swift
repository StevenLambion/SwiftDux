import XCTest
import Combine
import Dispatch
import SwiftDux
@testable import SwiftDuxExtras

final class PrintActionMiddlewareTests: XCTestCase {
  
  override func setUp() {
  }
  
  func testPrintAction() {
    var log = [String]()
    let store = Store(
      state: TestState(),
      reducer: TestReducer(),
      middleware: PrintActionMiddleware(printer: { log.append($0) })
    )
    store.send(TestAction.actionB)
    XCTAssertEqual(log, ["prepare", "actionB"])
  }
  
}

extension PrintActionMiddlewareTests {
  
  enum TestAction: Action, Equatable {
    case actionA
    case actionB
  }
  
  struct TestState: StateType {
    var test: String = ""
  }
  
  class TestReducer: Reducer {
    func reduce(state: TestState, action: TestAction) -> TestState {
      state
    }
  }
  
}
