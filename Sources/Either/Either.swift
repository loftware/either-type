/// A type that represents a value of either type `Left` or type `Right`.
///
/// This `Either` type is an enumeration with two cases, `Either.left(Left)`, and
/// `Either.right(Right)` with each case representing a value of one of the two
/// possible types in the `Either`. No particular importance should be placed on
/// which type is made the left or right case.
///
/// In the example below, the types of `a` and `b` are the same even though
/// they *represent* non-homogenous types:
///
///     let a: Either<Int, String> = Either(5)
///     let b: Either<Int, String> = Either("hello!")
///     print(type(of: a) == type(of: b))
///     // Prints "true"
///
/// Because `Either`s represent two underlying types, they cannot be mapped
/// operated on monomorphically. Instead, two ways of unwrapping them to a
/// single type must be provided.
@frozen
public enum Either<Left, Right> {
    /// A value of type `Left`.
    case left(Left)

    /// A value of type `Right`.
    case right(Right)

    /// An `Either` created by independently mapping over the `Left` and `Right`
    /// of this `Either`.
    ///
    /// This produces a new `Either` with its `Left` being the result type of
    /// the `left` closure, and its `Right` being the result type of the `right`
    /// closure as shown below:
    ///
    ///     let messageOrCode = Either<Int, String>.left(3)
    ///     let flipFlopped = messageOrCode.map(
    ///         left: { String($0) },
    ///         right: { Int($0)! })
    ///     print(result)
    ///     // Prints "Either<String, Int>("3")"
    ///
    /// - Parameter transformLeft: A closure that takes the `Left` of the
    ///   old `Either`, and produces a `Left` of the new `Either.`
    /// - Parameter transformRight: A closure that takes the `Right` of the
    ///   old `Either`, and produces a `Right` of the new `Either.`
    @inlinable
    public func map<U, V>(
        left transformLeft: (Left) throws -> U,
        right transformRight: (Right) throws -> V
    ) rethrows -> Either<U,V> {
        switch self {
        case .left(let l):
            return .left(try transformLeft(l))
        case .right(let r):
            return .right(try transformRight(r))
        }
    }

    /// Unwrap an `Either` by independently transforming the `Left` and `Right`
    /// types into a uniform `Result` type.
    ///
    ///     let messageOrCode = Either<Int, String>.left(3)
    ///     let isCodeGood = messageOrCode.map(
    ///         left: { $0 > 3 },
    ///         right: { $0.contains("success") })
    ///     print(result)
    ///     // Prints "false"
    ///
    /// - Parameter unwrapLeft: A closure that takes the `Left` of the
    ///   `Either`, and produces a `Result`.
    /// - Parameter unwrapRight: A closure that takes the `Right` of the
    ///   `Either`, and produces a `Result`.
    @inlinable
    public func unwrap<Result>(
        left unwrapLeft: (Left) throws -> Result,
        right unwrapRight: (Right) throws -> Result
    ) rethrows -> Result {
        switch self {
        case .left(let l):
            return try unwrapLeft(l)
        case .right(let r):
            return try unwrapRight(r)
        }
    }

    /// Unwrap an Either to a value of its `Right` type using a closure to
    /// convert `Left` values to `Right`s.
    ///
    /// - Parameter toRight: A closure that can convert a `Left` type into a
    ///   `Right` type.
    @inlinable
    public func unwrapToRight(
        _ toRight: (Left) throws -> Right
    ) rethrows -> Right {
        switch self {
        case .left(let l): return try toRight(l)
        case .right(let r): return r
        }
    }

    /// Unwrap an Either to a value of its `Left` type using a closure to
    /// convert `Right` values to `Left`s.
    ///
    /// - Parameter toLeft: A closure that can convert a `Right` type into a
    ///   `Left` type.
    @inlinable
    public func unwrapToLeft(
        _ toLeft: (Right) throws -> Left
    ) rethrows -> Left {
        switch self {
        case .left(let l): return l
        case .right(let r): return try toLeft(r)
        }
    }

    /// Flips the `left` and `right` of the `Either`.
    @inlinable
    public func flip() -> Either<Right, Left> {
        switch self {
        case .left(let l): return .right(l)
        case .right(let r): return .left(r)
        }
    }
}

extension Either where Left == Right {
    /// Unwrap a homogenous `Either` type to its underlying value.
    ///
    /// If `Left` and `Right` are homogenous types, there's no need for
    /// conversion and the underlying values in both cases can be used.
    @inlinable
    public func unwrap() -> Left {
        switch self {
        case .left(let l): return l
        case .right(let r): return r
        }
    }
}

extension Either: CustomDebugStringConvertible {
    public var debugDescription: String {
        let leftDescription = String(describing: Left.self)
        let rightDescription = String(describing: Right.self)
        var result = "Either<\(leftDescription),\(rightDescription)>("
        switch self {
        case .left(let l):
            result += "left("
            debugPrint(l, terminator: "", to: &result)
        case .right(let r):
            result += "right("
            debugPrint(r, terminator: "", to: &result)
        }
        result += "))"
        return result
    }
}

extension Either: CustomReflectable {
    public var customMirror: Mirror {
        switch self {
        case .left(let l):
        return Mirror(
            self,
            children: [ "left": l ],
            displayStyle: .enum)
        case .right(let r):
        return Mirror(
            self,
            children: [ "right": r ],
            displayStyle: .enum)
        }
    }
}

// Mark: Convenience initializers

// Attribution note: The following block of code up until the end attribution
// comment was inspired by similar extensions found in the `Either` type of the
// Swift standard library, located here:
// https://github.com/apple/swift/blob/master/stdlib/public/core/EitherSequence.swift
extension Either {
    /// An `Either` wrapping the `Left` type, with the unrepresented
    /// alternative `Right` type specified.
    ///
    /// This can be used to initialize an `Either` inline in a context where
    /// the `Right` type cannot be inferred. This is preferred over
    /// `Init(right:orLeft:)` for cases where it doesn't matter which type
    /// ends up on which side of the either.
    public init(_ left: Left, or other: Right.Type) { self = .left(left) }

    /// An `Either` wrapping the `Right` type, with the unrepresented
    /// alternative `Left` type specified.
    ///
    /// This can be used to initialize an `Either` inline in a context where
    /// the `Left` type cannot be inferred, and it matters that the value
    /// represented is of the `Right` type.
    public init(right: Right, orLeft other: Left.Type) {
        self = .right(right)
    }

    /// An `Either` containing a `Left` value.
    public init(_ left: Left) { self = .left(left) }

    /// An `Either` containing a `Right` value.
    public init(_ right: Right) { self = .right(right) }
}

// Mark: Standard conformances

extension Either: Comparable where Left: Comparable, Right: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case let (.left(a), .left(b)): return a < b
        case let (.right(a), .right(b)): return a < b
        case (.left, .right): return true
        case (.right, .left): return false
        }
    }
}

// End attribution note.

extension Either: Equatable where Left: Equatable, Right: Equatable {}
extension Either: Hashable where Left: Hashable, Right: Hashable {}

extension Either {
    internal enum CodingKeys: String, CodingKey {
        case left
        case right
    }
}

// Mark: Codable implementation

extension Either: Decodable where Left: Decodable, Right: Decodable {
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let left: Left? = try? values.decode(Left.self, forKey: .left)
        if let result = left {
            self = .left(result)
            return
        }
        let right: Right? = try? values.decode(
            Right.self, forKey: .right)
        guard let result = right else {
            let errorContext = DecodingError.Context(
                codingPath: [CodingKeys.right],
                debugDescription: """
                Neither value in `Either<\(String(describing: Left.self)), \
                \(String(describing: Right.self))>` present in encoded value.
                """)
            throw DecodingError.dataCorrupted(errorContext)
        }
        self = .right(result)
    }
}

extension Either: Encodable where Left: Encodable, Right: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .left(let l):
            try container.encode(l, forKey: .left)
        case .right(let r):
            try container.encode(r, forKey: .right)
        }
    }
}