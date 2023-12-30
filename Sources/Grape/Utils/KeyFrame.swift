public struct KeyFrame {
    public var elapsed: UInt = 0

    @inlinable @inline(__always)
    public init(rawValue: UInt) {
        self.elapsed = rawValue
    }

    @inlinable @inline(__always)
    public mutating func advance(by delta: UInt = 1) {
        elapsed += delta
    }

    @inlinable @inline(__always)
    public mutating func reset() {
        elapsed = 0
    }
}

extension KeyFrame: RawRepresentable, Equatable, Hashable, ExpressibleByIntegerLiteral {

    @inlinable @inline(__always)
    public var rawValue: UInt {
        return elapsed
    }

    @inlinable @inline(__always)
    public init(integerLiteral value: UInt) {
        self.init(rawValue: value)
    }

}

extension KeyFrame: CustomStringConvertible {
    @inlinable
    public var description: String {
        return elapsed.description
    }
}
