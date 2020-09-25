import XCTest
@testable import LoftDataStructures_Either

final class EitherTests: XCTestCase {
    typealias TestType = Either<Int, Bool>
    typealias TestType2 = Either<Bool, Int>
    let left: TestType = .left(13)
    let right: TestType = .right(true)


    func testMap() {
        let leftTransform = { $0 - 6 }
        let rightTransform = { !$0 }

        let leftResult = left.mapLeft {
            leftTransform($0)
        } right: {
            rightTransform($0)
        }

        let rightResult = right.mapLeft {
            leftTransform($0)
        } right: {
            rightTransform($0)
        }

        XCTAssertEqual(leftResult, .left(7))
        XCTAssertEqual(rightResult, .right(false))
    }

    func testMapLeft() {

    }

    func testMapRight() {

    }

    func testIndividualLeftRightUnwrap() {
        let leftTransform: (Int) -> String = { String($0) }
        let rightTransform: (Bool) -> String = { String($0) }
        let leftResult = left.unwrapLeft {
            leftTransform($0)
        } right: {
            rightTransform($0)
        }
        let rightResult = right.unwrapLeft {
            leftTransform($0)
        } right: {
            rightTransform($0)
        }
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
        XCTAssertEqual(Either<Int, Int>.left(13).unwrap(), 13)
        XCTAssertEqual(Either<Int, Int>.right(13).unwrap(), 13)
    }

    func testFlip() {
        XCTAssertEqual(left.flip(), Either<Bool, Int>.right(13))
        XCTAssertEqual(right.flip(), Either<Bool, Int>.left(true))

        // check to make sure that flipping two things of the same type
        // correctly flips the value's side
        XCTAssertEqual(Either<Int, Int>.left(13).flip(), .right(13))
        XCTAssertEqual(Either<Int, Int>.right(13).flip(), .left(13))
    }

    func testDescription() {
        XCTAssertEqual(left.description, "left(13)")
        XCTAssertEqual(right.description, "right(true)")
        XCTAssertEqual(left.flip().description, "right(13)")
    }

    func testDebugDescription() {
        XCTAssertEqual(left.debugDescription, "Either<_,Bool>(left(13))")
        XCTAssertEqual(right.debugDescription, "Either<Int,_>(right(true))")
        XCTAssertEqual(right.flip().debugDescription,
            "Either<_,Int>(left(true))")
    }

    func testComparable() {
        XCTAssert(Either<Int, Double>.left(13) < .right(15))
        XCTAssert(Either<Double, Int>.right(13) < .right(15))
        XCTAssert(Either<Int, Double>.left(13) < .right(13))
        XCTAssertFalse(Either<Double, Int>.right(13) < .left(13))
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
        let mappedData = left.mapRight {
            String($0)
        }
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

    func testLeftRightAccessors() {
        XCTAssertEqual(left.left!, 13)
        XCTAssertEqual(right.right!, true)
        XCTAssertEqual(left.right, nil)
        XCTAssertEqual(right.left, nil)
    }

    static var allTests = [
        ("testMap", testMap),
        ("testMapLeft", testMapLeft),
        ("testMapRight", testMapRight),
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
        ("testLeftRightAccessors", testLeftRightAccessors)
    ]
}
