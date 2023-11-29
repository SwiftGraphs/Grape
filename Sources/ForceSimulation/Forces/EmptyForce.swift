extension Kinetics {

    public struct EmptyForce: ForceProtocol {
        @inlinable
        public func apply() {}

        @inlinable
        public func bindKinetics(_ kinetics: Kinetics) {}
    }
}
