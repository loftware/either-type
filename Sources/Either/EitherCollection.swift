

extension Sequence {
    public func lefts<L, R>() -> [L] where Self.Element == Either<L, R> {
        return self
            .filter {
                if case .left(_) = $0 { return true } else { return false }
            }
            .map { $0.left! }
    }

    func rights<L, R>() -> [R] where Self.Element == Either<L, R> {
        return self
            .filter {
                if case .right(_) = $0 { return true } else { return false }
            }
            .map { $0.right! }
    }
}


public typealias LazyLeftSequence<Element, Wrapped: Sequence> =
    LazyMapSequence<LazyFilterSequence<LazySequence<Wrapped>.Elements>, Element>
public typealias LazyRightSequence = LazyLeftSequence

extension LazySequenceProtocol {
    public func lefts<L, R>() -> LazyLeftSequence<L, Self.Elements>
    where Self.Element == Either<L, R> {
        return self.lazy
            .filter {
                if case .left(_) = $0 { return true } else { return false }
            }
            .map { $0.left! }
    }

    func rights<L, R>() -> LazyRightSequence<R, Self.Elements>
    where Self.Element == Either<L, R> {
        return self.lazy
            .filter {
                if case .right(_) = $0 { return true } else { return false }
            }
            .map { $0.right! }
    }
}