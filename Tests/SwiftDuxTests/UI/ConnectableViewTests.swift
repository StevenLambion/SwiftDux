import XCTest
import Combine
import SwiftUI
import SnapshotTesting
@testable import SwiftDux

#if os(iOS)
final class ConnectableViewTests: XCTestCase {
  var store: Store<TestState>!
  
  override func setUp() {
    self.store = Store(state: TestState(), reducer: TestReducer())
  }
  
  func testConnectableView() {
    let view = TestView().provideStore(store).frame(width: 100, height: 100)
    store.send(TestAction.setName("Test"))
    assertSnapshot(matching: view, as: .image)
  }
}

extension ConnectableViewTests {
  
  struct TestState: Equatable {
    var name: String = ""
  }
  
  enum TestAction: Action {
    case setName(String)
  }
  
  final class TestReducer: Reducer {
    func reduce(state: TestState, action: TestAction) -> TestState {
      var state = state
      switch action {
      case .setName(let name):
        state.name = name
      }
      return state
    }
  }
  
  struct TestView: ConnectableView {
    
    func map(state: TestState) -> String? {
      state.name
    }
    
    func body(props: String) -> some View {
      Text(props)
    }
  }
}
#endif
