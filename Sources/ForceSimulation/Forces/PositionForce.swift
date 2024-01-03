extension Kinetics {

    public typealias TargetOnDirection = AttributeDescriptor<Vector.Scalar>
    public enum DirectionOfPositionForce: Equatable {
        case x
        case y
        case z
        case entryOfVector(Int)
    }
    public typealias PositionStrength = AttributeDescriptor<Vector.Scalar>

    /// A force that moves nodes to a target position.
    ///
    /// Center force is relatively fast, the complexity is `O(n)`,
    /// where `n` is the number of nodes.
    /// See [Position Force - D3](https://d3js.org/d3-force/position).
    public struct PositionForce: ForceProtocol {

        // @usableFromInline var kinetics: Kinetics! = nil

        public var strength: PositionStrength
        public var direction: Int
        public var calculatedStrength: UnsafeArray<Vector.Scalar>! = nil
        public var targetOnDirection: TargetOnDirection
        public var calculatedTargetOnDirection: UnsafeArray<Vector.Scalar>! = nil

        @inlinable
        public func apply() {
            // assert(self.kinetics != nil, "Kinetics not bound to force")
            // let alpha = kinetics.alpha
            // let lane = self.direction
            // for i in kinetics.range {
            //     kinetics.velocity[i][lane] +=
            //         (self.calculatedTargetOnDirection[i] - kinetics.position[i][lane])
            //         * self.calculatedStrength[i] * alpha
            // }
        }

        @inlinable
        public func apply(to kinetics: inout Kinetics) {
            let alpha = kinetics.alpha
            let lane = self.direction
            for i in kinetics.range {
                kinetics.velocity[i][lane] +=
                    (self.calculatedTargetOnDirection[i] - kinetics.position[i][lane])
                    * self.calculatedStrength[i] * alpha
            }
        }

        @inlinable
        public mutating func bindKinetics(_ kinetics: Kinetics) {
            // self.kinetics = kinetics
            self.calculatedTargetOnDirection = self.targetOnDirection.calculateUnsafe(
                for: kinetics.validCount)
            self.calculatedStrength = self.strength.calculateUnsafe(for: kinetics.validCount)
        }

        @inlinable
        public init(
            direction: DirectionOfPositionForce,
            targetOnDirection: TargetOnDirection,
            strength: PositionStrength = .constant(1.0)
        ) {
            self.strength = strength
            self.direction = direction.lane
            self.targetOnDirection = targetOnDirection
        }

        @inlinable
        public func dispose() {}
    }

}

extension Kinetics.DirectionOfPositionForce {
    @inlinable
    var lane: Int {
        switch self {
        case .x: return 0
        case .y: return 1
        case .z: return 2
        case .entryOfVector(let i): return i
        }
    }
}
