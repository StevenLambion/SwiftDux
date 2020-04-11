import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
      testCase(ActionPlanTests.allTests),
        testCase(PerformanceTests.allTests),
        testCase(OrderedStateTests.allTests),
        testCase(StoreActionDispatcherTests.allTests),
        testCase(StoreTests.allTests),
        testCase(JSONStatePersistorTests.allTests),
        testCase(PersistStateMiddlewareTests.allTests),
        testCase(PrintActionMiddlewareTests.allTests),
        testCase(TodoExampleTests.allTests),
    ]
}
#endif
