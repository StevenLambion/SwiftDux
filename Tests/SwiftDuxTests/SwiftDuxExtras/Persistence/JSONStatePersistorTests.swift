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

class JSONStatePersistorTests: XCTestCase {
  var location: TestLocation!
  
  override func setUp() {
    location = TestLocation()
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
  func testSaveState() {
    let persistor = JSONStatePersistor<TestState>(location: location)
    persistor.save(TestState(name: "Bob"))
    XCTAssertEqual(String(data: location.savedData!, encoding: .utf8), #"{"name":"Bob"}"#)
  }
  
  func testSaveStateWithPubisher() {
    let persistor = JSONStatePersistor<TestState>(location: location)
    let expectation = XCTestExpectation()
    let cancellable = location.didSave.dropFirst().sink { expectation.fulfill() }
    let publisher = [TestState(name: "John"), TestState(name: "Bob")].publisher
    .delay(for: .milliseconds(10), scheduler: RunLoop.main)
    let persistCancellable = publisher.persist(with: persistor)
    
    wait(for: [expectation], timeout: 10)
    cancellable.cancel()
    persistCancellable.cancel()
    XCTAssertEqual(persistor.restore(), TestState(name: "Bob"))
  }
  
  func testSaveStateFromStore() {
    let persistor = JSONStatePersistor<TestState>(location: location)
    let store = Store(state: TestState(), reducer: TestReducer())
    let expectation = XCTestExpectation()
    let cancellable = location.didSave.first().sink { expectation.fulfill() }
    let persistCancellable = persistor.save(from: store)
      
    store.send(TestAction.setName("John"))
    store.send(TestAction.setName("Bilbo"))
    
    wait(for: [expectation], timeout: 10)
    cancellable.cancel()
    persistCancellable.cancel()
    XCTAssertEqual(persistor.restore(), TestState(name: "Bilbo"))
  }
  
  func testRestoreState() {
    let persistor = JSONStatePersistor<TestState>(location: location)
    persistor.save(TestState(name: "Bob"))
    XCTAssertEqual(persistor.restore(), TestState(name: "Bob"))
  }
  
  static var allTests = [
    ("testSaveState", testSaveState),
    ("testSaveStateWithPubisher", testSaveStateWithPubisher),
    ("testSaveStateFromStore", testSaveStateFromStore),
    ("testRestoreState", testRestoreState),
  ]
}

extension JSONStatePersistorTests {
  
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
    
    var savedData: Data? = nil
    var canSave: Bool = true
    
    var didSave = PassthroughSubject<Void, Never>()
    
    func save(_ data: Data) -> Bool {
      guard canSave == true else { return false }
      self.savedData = data
      self.didSave.send()
      return true
    }
    
    func restore() -> Data? {
      savedData
    }
  }
}
