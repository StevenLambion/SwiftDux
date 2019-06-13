import XCTest

import SwiftDuxTests

var tests = [XCTestCaseEntry]()
tests += StoreTests.allTests()
XCTMain(tests)
