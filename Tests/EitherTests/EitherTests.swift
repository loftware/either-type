import XCTest
@testable import Either

final class EitherTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Either().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
