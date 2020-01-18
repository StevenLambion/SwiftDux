import XCTest
import Combine
import Dispatch
@testable import SwiftDux

final class ModifiedActionTests: XCTestCase {

  override func setUp() {
  }
  
  func testCreateModifiedAction() {
    let modifiedAction = ModifiedAction(action: TestAction.actionA)
    XCTAssertTrue(modifiedAction.action as? TestAction == TestAction.actionA)
  }
  
  func testCreateModifiedActionWithPreviousAction() {
    let modifiedActionA = ModifiedAction(action: TestAction.actionA)
    let modifiedActionB = modifiedActionA.modified(with: TestAction.actionB)
    XCTAssertTrue(modifiedActionB.action as? TestAction == TestAction.actionB)
    XCTAssertTrue(modifiedActionB.previousActions[0] as? TestAction == TestAction.actionA)
  }

}

extension ModifiedActionTests {
  
  enum TestAction: Action, Equatable {
    case actionA
    case actionB
  }
  
}
