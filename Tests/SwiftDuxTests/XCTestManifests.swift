import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(StoreTests.allTests),
        testCase(ActionPlanTests.allTests),
        testCase(OrderedStateTests.allTests),
    ]
}
#endif
