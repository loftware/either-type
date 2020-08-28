import XCTest
@testable import Either

final class EitherCollectionTests: XCTestCase {
    let eithers: Array<Either<Int, String>> = [
        Either(1),
        Either("a"),
        Either(2),
        Either("b"),
        Either(3),
        Either("c"),
    ]

    let empty: Array<Either<Int, String>> = []

    let homogeneous: Array<Either<Int, Int>> = [
        Either(left: 1),
        Either(left: 2),
        Either(right: 3),
        Either(right: 4),
    ]

    func testStrictLefts() {
        XCTAssertEqual(eithers.lefts(), [1,2,3])
        XCTAssertEqual(empty.lefts(), [])
        XCTAssertEqual(homogeneous.lefts(), [1, 2])
    }

    func testStrictRights() {
        XCTAssertEqual(eithers.rights(), ["a", "b", "c"])
        XCTAssertEqual(empty.rights(), [])
        XCTAssertEqual(homogeneous.rights(), [3, 4])
    }

    func testLazyLefts() {
        var lazinessBroken = false
        let mappedLefts = eithers.lazy
            .map { (either: Either<Int, String>) -> Either<Int, String> in
                lazinessBroken = true
                return either
            }
            .lefts()
            .map { (left: Int) -> Int in
                lazinessBroken = true
                return left + 1
            }
        XCTAssertFalse(lazinessBroken, "Failed to maintain laziness")
        XCTAssertEqual(Array(mappedLefts), [2, 3, 4])
        XCTAssertTrue(lazinessBroken)
    }

    func testLazyRights() {
        var lazinessBroken = false
        let mappedRights = eithers.lazy
            .map { (either: Either<Int, String>) -> Either<Int, String> in
                lazinessBroken = true
                return either
            }
            .rights()
            .map { (right: String) -> String in
                lazinessBroken = true
                return right + "!"
            }
        XCTAssertFalse(lazinessBroken, "Failed to maintain laziness")
        XCTAssertEqual(Array(mappedRights), ["a!", "b!", "c!"])
        XCTAssertTrue(lazinessBroken)
    }

    static var allTests = [
        ("testStrictLefts", testStrictLefts),
        ("testStrictRights", testStrictRights),
        ("testLazyLefts", testLazyLefts),
        ("testLazyRights", testLazyRights),
    ]
}

