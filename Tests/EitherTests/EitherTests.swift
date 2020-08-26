import XCTest
@testable import Either

final class EitherTests: XCTestCase {
    typealias TestType = Either<Int, Bool>
    typealias TestType2 = Either<Bool, Int>
    let left: TestType = .left(13)
    let right: TestType = .right(true)

    func testInitializers() {
        let left2 = TestType(13)
        let left3: TestType = Either(13)
        let left4 = Either(13, or: Bool.self)

        let right2 = TestType(true)
        let right3: TestType = Either(true)
        let right4 = Either(right: true, orLeft: Int.self)

        XCTAssert(left == left2 && left2 == left3 && left3 == left4,
            "Eithers initialized to the same value were not equivalent")
        XCTAssert(right == right2 && right2 == right3 && right3 == right4,
            "Eithers initialized to the same value were not equivalent")
        XCTAssert(type(of: left) == type(of: right), """
            Types of left and right constructed eithers were not equivalent
            """)
    }

    func testMap() {
        let leftTransform = { $0 - 6 }
        let rightTransform = { !$0 }

        let leftResult = left.map(
            left: leftTransform,
            right: rightTransform)

        let rightResult = right.map(
            left: leftTransform,
            right: rightTransform)

        XCTAssertEqual(leftResult, Either(7, or: Bool.self))
        XCTAssertEqual(rightResult, Either(right: false, orLeft: Int.self))
    }

    func testIndividualLeftRightUnwrap() {
        let leftTransform: (Int) -> String = { String($0) }
        let rightTransform: (Bool) -> String = { String($0) }
        let leftResult = left.unwrap(left: leftTransform, right: rightTransform)
        let rightResult = right.unwrap(left: leftTransform,
            right: rightTransform)
        XCTAssertEqual(leftResult, "13")
        XCTAssertEqual(rightResult, "true")
    }

    func testToLeftTypeUnwrap() {
        let a = left.unwrapToLeft { $0 ? 100 : 0 }
        XCTAssertEqual(a, 13, "To-left unwrap transformed left value")
        let b = right.unwrapToLeft { $0 ? 100 : 0 }
        XCTAssertEqual(b, 100, "Improperly transformed right value to left")
    }

    func testToRightTypeUnwrap() {
        let a = right.unwrapToRight { $0 > 20 }
        XCTAssertEqual(a, true, "To-right unwrap transformed right value")
        let b = left.unwrapToRight { $0 > 20 }
        XCTAssertEqual(b, false, "Improperly transformed left value to right")
    }

    func testSameTypeUnwrap() {
        XCTAssertEqual(Either(13, or: Int.self).unwrap(), 13)
        XCTAssertEqual(Either(right: 13, orLeft: Int.self).unwrap(), 13)
    }

    func testFlip() {
        XCTAssertEqual(left.flip(), Either(right: 13, orLeft: Bool.self))
        XCTAssertEqual(right.flip(), Either(true, or: Int.self))

        // check to make sure that flipping two things of the same type
        // correctly flips the value's side
        XCTAssertEqual(Either(13, or: Int.self).flip(),
            Either(right: 13, orLeft: Int.self))
        XCTAssertEqual(Either(right: 13, orLeft: Int.self).flip(),
            Either(13, or: Int.self))
    }

    func testDebugDescription() {
        XCTAssertEqual(left.debugDescription, "Either<Int,Bool>(left(13))")
        XCTAssertEqual(right.debugDescription, "Either<Int,Bool>(right(true))")
        XCTAssertEqual(right.flip().debugDescription,
            "Either<Bool,Int>(left(true))")
    }

    func testComparable() {
        XCTAssert(Either(13, or: Double.self) < Either(15, or: Double.self))
        XCTAssert(Either(right: 13, orLeft: Double.self) <
            Either(right: 15, orLeft: Double.self))
        XCTAssert(Either(13, or: Double.self) <
            Either(right: 13, orLeft: Double.self))
        XCTAssertFalse(Either(right: 13, orLeft: Double.self) <
            Either(13, or: Double.self))
    }

    func testEncoding() throws {
        let encoder = JSONEncoder()
        let data1 = try encoder.encode(left)
        let data2 = try encoder.encode(right)

        let leftString = String(data: data1, encoding: .utf8)!

        XCTAssertEqual("{\"left\":13}", leftString)
        XCTAssertEqual("{\"right\":true}",
            String(data: data2, encoding: .utf8)!)

        // Ensure that changing the unrepresented type doesn't change the
        // encoding of a value.
        let mappedData = left.map(
            left: { $0 },
            right: { String($0) }
        )
        let data3 = try encoder.encode(mappedData)
        XCTAssertEqual(leftString, String(data: data3, encoding: .utf8)!)
    }

    func testDecoding() throws {
        let leftData = "{\"left\":13}".data(using: .utf8)!
        let rightData = "{\"right\":true}".data(using: .utf8)!


        let decoder = JSONDecoder()

        let decodedLeft = try decoder.decode(TestType.self, from: leftData)
        let decodedRight = try decoder.decode(TestType.self, from: rightData)

        XCTAssertEqual(decodedLeft, left)
        XCTAssertEqual(decodedRight, right)

        // Ensure that mismatched right and left data types fail to decode.
        XCTAssertThrowsError(try decoder.decode(
            TestType2.self, from: leftData))
    }

    func testDecodeEmptyData() throws {
        let emptyData = "{}".data(using: .utf8)!
        let decoder = JSONDecoder()
        XCTAssertThrowsError(try decoder.decode(TestType.self, from :emptyData))
    }

    func testForceUnwrap() {
        XCTAssertEqual(left.forceUnwrapLeft(), 13)
        XCTAssertEqual(right.forceUnwrapRight(), true)
    }

    static var allTests = [
        ("testInitializers", testInitializers),
        ("testMap", testMap),
        ("testIndividualizedLeftRightUnwrap", testIndividualLeftRightUnwrap),
        ("testToLeftTypeUnwrap", testToLeftTypeUnwrap),
        ("testToRightTypeUnwrap", testToRightTypeUnwrap),
        ("testSameTypeUnwrap", testSameTypeUnwrap),
        ("testFlip", testFlip),
        ("testDebugDescription", testDebugDescription),
        ("testComparable", testComparable),
        ("testEncoding", testEncoding),
        ("testDecoding", testDecoding),
        ("testDecodeEmptyData", testDecodeEmptyData),
        ("testForceUnwrap", testForceUnwrap)
    ]
}
