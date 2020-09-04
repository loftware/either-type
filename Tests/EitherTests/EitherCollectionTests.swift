import XCTest
@testable import Either

final class EitherCollectionTests: XCTestCase {
    let eithers: [Either<Int, String>] = [
        .left(1),
        .right("a"),
        .left(2),
        .right("b"),
        .left(3),
        .right("c"),
    ]

    let empty: [Either<Int, String>] = []

    let homogeneous: [Either<Int, Int>] = [
        .left(1),
        .left(2),
        .right(3),
        .right(4),
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

