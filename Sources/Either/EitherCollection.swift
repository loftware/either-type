extension Sequence {
    /// Returns an array of the underlying `left` values in this `Sequence` of
    /// `Either`s.
    ///
    /// This function unwraps, and then returns all of the left values, so
    /// the result is an array of `Left`s, not an array of `.left`s. For
    /// example:
    ///
    ///     let eithers: [Either<Int, Bool>] = [
    ///         Either(1), Either(true), Either(2), Either(false)
    ///     ]
    ///     print(eithers.lefts())
    ///     // Prints "[1, 2]"
    public func lefts<L, R>() -> [L] where Self.Element == Either<L, R> {
        return self
            .filter {
                if case .left(_) = $0 { return true } else { return false }
            }
            .map { $0.left! }
    }

    /// Returns an array of the underlying right values in the `Sequence` of
    /// `Either`s.
    ///
    /// This function unwraps, and then returns all of the right values, so
    /// the result is an array of `Right`s, not an array of `.right`s. For
    /// example:
    ///
    ///     let eithers: [Either<Int, Bool>] = [
    ///         Either(1), Either(true), Either(2), Either(false)
    ///     ]
    ///     print(eithers.rights())
    ///     // Prints "[true, false]"
    func rights<L, R>() -> [R] where Self.Element == Either<L, R> {
        return self
            .filter {
                if case .right(_) = $0 { return true } else { return false }
            }
            .map { $0.right! }
    }
}

/// A `LazySequenceProtocol` containing the underlying lefts of a
/// sequence of `Either`s.
public typealias LazyLeftSequence<Element, Wrapped: Sequence> =
    LazyMapSequence<LazyFilterSequence<LazySequence<Wrapped>.Elements>, Element>
/// A `LazySequenceProtocol` containing the underlying rights of a
/// sequence of `Either`s.
public typealias LazyRightSequence = LazyLeftSequence

extension LazySequenceProtocol {
    /// A lazy sequence containing the underlying left values of this sequence
    /// of `Either`s.
    public func lefts<L, R>() -> LazyLeftSequence<L, Self.Elements>
    where Self.Element == Either<L, R> {
        return self.lazy
            .filter {
                if case .left(_) = $0 { return true } else { return false }
            }
            .map { $0.left! }
    }

    /// A lazy sequence containing the underlying right values in this sequence
    /// of `Either`s.
    func rights<L, R>() -> LazyRightSequence<R, Self.Elements>
    where Self.Element == Either<L, R> {
        return self.lazy
            .filter {
                if case .right(_) = $0 { return true } else { return false }
            }
            .map { $0.right! }
    }
}