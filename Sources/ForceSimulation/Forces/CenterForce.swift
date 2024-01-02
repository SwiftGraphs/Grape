extension Kinetics {
    /// A force that drives nodes towards the center.
    ///
    /// Center force is relatively fast, the complexity is `O(n)`,
    /// where `n` is the number of nodes.
    /// See [Collide Force - D3](https://d3js.org/d3-force/collide).
    public struct CenterForce: ForceProtocol {

        @usableFromInline var kinetics: Kinetics! = nil

        @inlinable
        public func apply() {
            assert(self.kinetics != nil, "Kinetics not bound to force")
            var meanPosition = Vector.zero
            let positionBufferPointer = kinetics.position.mutablePointer
            for i in kinetics.range {
                meanPosition += positionBufferPointer[i]  //.position
            }
            let delta = meanPosition * (self.strength / Vector.Scalar(kinetics.validCount))

            for i in kinetics.range {
                positionBufferPointer[i] -= delta
            }
        }

        @inlinable
        public func apply(to kinetics: inout Kinetics) {
            var meanPosition = Vector.zero
            let positionBufferPointer = kinetics.position.mutablePointer
            for i in 0..<kinetics.validCount {
                meanPosition += positionBufferPointer[i]  //.position
            }
            let delta = meanPosition * (self.strength / Vector.Scalar(kinetics.validCount))

            for i in kinetics.range {
                positionBufferPointer[i] -= delta
            }
        }

        @inlinable
        public mutating func bindKinetics(_ kinetics: Kinetics) {
            self.kinetics = kinetics
        }

        public var center: Vector
        public var strength: Vector.Scalar

        @inlinable
        public
            init(center: Vector, strength: Vector.Scalar)
        {
            self.center = center
            self.strength = strength
        }

        @inlinable
        public func dispose() {}

    }

}
