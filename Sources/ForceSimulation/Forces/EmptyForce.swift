extension Kinetics {

    public struct EmptyForce: ForceProtocol {
        

        @inlinable
        public func apply(to kinetics: inout Kinetics) {}

        @inlinable
        public func bindKinetics(_ kinetics: Kinetics) {}

        @inlinable
        public func dispose() {}
    }
}
