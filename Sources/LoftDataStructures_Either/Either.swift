/// A type that represents a value of either type `Left` or type `Right`.
///
/// Because `Either`s contain one of two underlying types, they cannot be
/// operated on monomorphically. Operations that act on `Either`s must provide
/// ways of handling the `Left` and `Right` types individually.
@frozen
public enum Either<Left, Right> {
    /// A value of type `Left`.
    case left(Left)

    /// A value of type `Right`.
    case right(Right)

    /// An `Either` created by transforming the left of this either (if it has
    /// one) leaving right values unchanged.
    @inlinable
    public func mapLeft<U>(
        _ transformLeft: (Left) throws -> U
    ) rethrows -> Either<U, Right> {
        switch self {
        case .left(let l): return .left(try transformLeft(l))
        case .right(let r): return .right(r)
        }
    }

    /// An `Either` created by transforming the right of this either (if it has
    /// one) leaving left values unchanged.
    @inlinable
    public func mapRight<U>(
        _ transformRight: (Right) throws -> U
    ) rethrows -> Either<Left, U> {
        switch self {
        case .left(let l): return .left(l)
        case .right(let r): return .right(try transformRight(r))
        }
    }

    /// An `Either` created by independently mapping over the `Left` and `Right`
    /// of this `Either`.
    @inlinable
    public func mapLeft<NewLeft, NewRight>(
        _ transformLeft: (Left) throws -> NewLeft,
        right transformRight: (Right) throws -> NewRight
    ) rethrows -> Either<NewLeft, NewRight> {
        switch self {
        case .left(let l):
            return .left(try transformLeft(l))
        case .right(let r):
            return .right(try transformRight(r))
        }
    }

    /// Unwrap an `Either` by independently transforming the `Left` and `Right`
    /// types into a single `Result` type.
    @inlinable
    public func unwrapLeft<Result>(
        _ unwrapLeft: (Left) throws -> Result,
        right unwrapRight: (Right) throws -> Result
    ) rethrows -> Result {
        switch self {
        case .left(let l):
            return try unwrapLeft(l)
        case .right(let r):
            return try unwrapRight(r)
        }
    }

    /// Unwrap an Either to a value of its `Left` type using a closure to
    /// convert `Right` values to `Left`s.
    @inlinable
    public func unwrapToLeft(
        _ transformRightToLeft: (Right) throws -> Left
    ) rethrows -> Left {
        switch self {
        case .left(let l): return l
        case .right(let r): return try transformRightToLeft(r)
        }
    }

    /// Unwrap an Either to a value of its `Right` type using a closure to
    /// convert `Left` values to `Right`s.
    @inlinable
    public func unwrapToRight(
        _ transformLeftToRight: (Left) throws -> Right
    ) rethrows -> Right {
        switch self {
        case .left(let l): return try transformLeftToRight(l)
        case .right(let r): return r
        }
    }

    /// The `Left` value of the `Either` if it has one, otherwise `nil`.
    @inlinable
    public var left: Left? {
        guard case let .left(result) = self else { return nil }
        return result
    }

    /// The `Right` value of the `Either` if it has one, otherwise `nil`.
    @inlinable
    public var right: Right? {
        guard case let .right(result) = self else { return nil }
        return result
    }

    /// Switches the `left` and `right` of the `Either`.
    @inlinable
    public func flip() -> Either<Right, Left> {
        switch self {
        case .left(let l): return .right(l)
        case .right(let r): return .left(r)
        }
    }
}

extension Either where Left == Right {
    /// Unwrap a homogeneous `Either` type to its underlying value.
    @inlinable
    public func unwrap() -> Left {
        switch self {
        case .left(let l): return l
        case .right(let r): return r
        }
    }
}

extension Either: CustomStringConvertible
where Left: CustomStringConvertible, Right: CustomStringConvertible {
    public var description: String {
        switch self {
        case .left(let l): return "left(\(l.description))"
        case .right(let r): return "right(\(r.description))"
        }
    }
}

extension Either: CustomDebugStringConvertible {
    public var debugDescription: String {
        var result = ""
        switch self {
        case .left(let l):
            result += "Either<_,\(String(describing: Right.self))>(left("
            debugPrint(l, terminator: "", to: &result)
        case .right(let r):
            result += "Either<\(String(describing: Left.self)),_>(right("
            debugPrint(r, terminator: "", to: &result)
        }
        result += "))"
        return result
    }
}

// Mark: Standard conformances

// Attribution note: The following block of code up until the end attribution
// comment was inspired by similar extensions found in the `Either` type of the
// Swift standard library, located here:
// https://github.com/apple/swift/blob/master/stdlib/public/core/EitherSequence.swift

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
                Neither value in \(String(describing: Self.self)) is present \
                in encoded value.
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