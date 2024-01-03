extension Kinetics {

    public typealias RadialBound = AttributeDescriptor<Vector.Scalar>
    public typealias RadialStrength = AttributeDescriptor<Vector.Scalar>

    /// A force that applies a radial force to all nodes.
    ///
    /// Center force is relatively fast, the complexity is `O(n)`,
    /// where `n` is the number of nodes.
    /// See [Position Force - D3](https://d3js.org/d3-force/position).
    public struct RadialForce: ForceProtocol {

        // @usableFromInline var kinetics: Kinetics! = nil
        public var radius: RadialBound
        public var strength: RadialStrength
        public var center: Vector

        @usableFromInline
        var calculatedRadius: UnsafeArray<Vector.Scalar>! = nil

        @usableFromInline
        var calculatedStrength: UnsafeArray<Vector.Scalar>! = nil

        @inlinable
        public func apply() {
            // assert(self.kinetics != nil, "Kinetics not bound to force")

            // let alpha = kinetics.alpha
            // for i in kinetics.range {
            //     let nodeId = i
            //     let deltaPosition = (kinetics.position[i] - self.center).jiggled(by: kinetics.randomGenerator) //.jiggled()
            //     let r = (deltaPosition).length()
            //     let k =
            //         (self.calculatedRadius[nodeId]
            //             * self.calculatedStrength[nodeId] * alpha) / r
            //     kinetics.velocity[i] += deltaPosition * k
            // }
        }

        @inlinable
        public func apply(to kinetics: inout Kinetics) {
            let alpha = kinetics.alpha
            for i in kinetics.range {
                let deltaPosition = (kinetics.position[i] - self.center).jiggled(
                    by: &kinetics.randomGenerator)  //.jiggled()
                let r = deltaPosition.length()
                let k =
                    (self.calculatedRadius[i]
                        * self.calculatedStrength[i] * alpha) / r
                kinetics.velocity[i] += deltaPosition * k
            }
        }

        @inlinable
        public mutating func bindKinetics(_ kinetics: Kinetics) {
            // self.kinetics = kinetics
            self.calculatedRadius = self.radius.calculateUnsafe(for: kinetics.validCount)
            self.calculatedStrength = self.strength.calculateUnsafe(for: kinetics.validCount)
        }

        @inlinable
        public init(center: Vector, radius: RadialBound, strength: RadialStrength) {
            self.center = center
            self.radius = radius
            self.strength = strength
        }

        @inlinable
        public func dispose() {}
    }

}
