import XCTest

import EitherTests

var tests = [XCTestCaseEntry]()
tests += EitherTests.allTests()
tests += EitherCollection.allTests()
XCTMain(tests)
