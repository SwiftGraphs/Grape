extension Kinetics {

    public final class CenterForce: ForceProtocol {

        var kinetics: Kinetics! = nil

        public func apply() {
            assert(self.kinetics != nil, "Kinetics not bound to force")
            var meanPosition = Vector.zero
            for n in kinetics.position {
                meanPosition += n  //.position
            }
            let delta = meanPosition * (self.strength / Vector.Scalar(kinetics.validCount))

            for i in 0..<kinetics.validCount {
                kinetics.position[i] -= delta
            }
        }

        public func bindKinetics(_ kinetics: Kinetics) {
            self.kinetics = kinetics
        }

        public var center: Vector.Scalar
        public var strength: Vector.Scalar

        @inlinable
        internal
            init(center: Vector.Scalar, strength: Vector.Scalar)
        {
            self.center = center
            self.strength = strength
        }

    }

}
