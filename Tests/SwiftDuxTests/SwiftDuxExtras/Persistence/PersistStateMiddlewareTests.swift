//
//  JSONStatePersistorTests.swift
//  SwiftDuxTests
//
//  Created by Steven Lambion on 1/14/20.
//

import XCTest
import SwiftDux
import Combine
@testable import SwiftDuxExtras

class PersistStateMiddlewareTests: XCTestCase {
  var location: TestLocation!
  var persistor: JSONStatePersistor<TestState>!
  
  override func setUp() {
    location = TestLocation()
    persistor = JSONStatePersistor<TestState>(location: location)
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
  func createStore<M>(with middleware: M) -> Store<TestState> where M: Middleware, M.State == TestState {
    Store(state: TestState(), reducer: TestReducer(), middleware: middleware)
  }
  
  func testSaveState() {
    let store = createStore(with: PersistStateMiddleware(persistor))
    let expectation = XCTestExpectation()
    let cancellable = location.savedData.dropFirst().compactMap { $0 }.sink { _ in expectation.fulfill() }
    store.send(TestAction.setName("John"))
    wait(for: [expectation], timeout: 10.0)
    XCTAssertEqual(String(data: location.savedData.value, encoding: .utf8), #"{"name":"John"}"#)
    XCTAssertNotNil(cancellable)
  }
  
  func testRestoreState() {
    let store = createStore(with: PersistStateMiddleware(persistor))
    XCTAssertEqual(store.state.name, "Rose")
  }
  
  static var allTests = [
    ("testSaveState", testSaveState),
    ("testRestoreState", testRestoreState),
  ]
}

extension PersistStateMiddlewareTests {
  
  enum TestAction: Action {
    case setName(String)
  }
  
  struct TestState: StateType {
    var name: String = ""
  }
  
  class TestReducer: Reducer {
    
    func reduce(state: TestState, action: TestAction) -> TestState {
      switch action {
      case .setName(let name):
        return TestState(name: name)
      }
    }
  }
  
  final class TestLocation: StatePersistentLocation {
    
    var savedData = CurrentValueSubject<Data, Never>(try! JSONEncoder().encode(TestState(name: "Rose")))
    var canSave: Bool = true
    
    var didSave = PassthroughSubject<Void, Never>()
    
    func save(_ data: Data) -> Bool {
      guard canSave == true else { return false }
      self.savedData.send(data)
      self.didSave.send()
      return true
    }
    
    func restore() -> Data? {
      savedData.value
    }
    
  }
}
