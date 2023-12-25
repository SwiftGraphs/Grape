public struct KeyFrame {
    public var elapsed: UInt = 0

    @_transparent
    public init(rawValue: UInt) {
        self.elapsed = rawValue
    }

    @_transparent
    public mutating func advance(by delta: UInt = 1) {
        elapsed += delta
    }

    @_transparent
    public mutating func reset() {
        elapsed = 0
    }
}

extension KeyFrame: RawRepresentable, Equatable, Hashable, ExpressibleByIntegerLiteral {

    @_transparent
    public var rawValue: UInt {
        return elapsed
    }

    @_transparent
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
