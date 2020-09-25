# LoftDataStructures_Either

A general purpose either type and basic utilities to support its use.

## API Notes

### Multiple Closure APIs

The APIs in this package that utilize multiple closures are optimized for the
use of the multiple trailing closures feature at the call site. This means
attaching the description of the first closure argument to the end of the
function name, and providing a descriptive label for further closure arguments
that is intended for use as a second trailing closure label.

### Either Enum Case Naming

A lot of thought was put into deciding what names to use for the enum cases of
the `Either` type. While `Either` types in other languages have traditionally
used `left` and `right` as names for the two cases, we didn't find this alone to
be a strong enough justification for utilizing the same convention. We
considered a number of alternative names for the cases, and their generic
argument names. The two biggest alternatives were `T0` / `T1`, and `A` / `B`. We
found the first to be problematic as while it works fine in the context of
generic arguments, it doesn't present any natural name for the enum cases
themselves. `A` / `B` clearly lends itself to the names `a` and `b` for the enum
cases, however it has some readability issues. For example, consider the
following line:

```swift
    let something = [.a(1), .b("hello"), .a(7), .b("world")]
```

This looks difficult enough to read already, but it also has the following
additional problem. Having enum cases `a`, and `b` on an initial read doesn't
tell you you've seen all the cases. It might, for example, make someone think a
`c` case exists. `left` and `right` on the other hand seem like a much more
natural pair. At worst, someone might think that this pair implies the existence
of an `up` and `down` case, but that seems unlikely. At the very least, `left`
and `right` are a much more obviously complete set.