import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(EitherTests.allTests),
        testCase(EitherCollectionTests.allTests)
    ]
}
#endif
