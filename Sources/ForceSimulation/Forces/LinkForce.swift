extension Kinetics {
    public final class LinkForce: ForceProtocol {
        @inlinable
        public func apply() {

        }

        @inlinable
        internal var links: [EdgeID<Int>]

        @inlinable
        public func bindKinetics(_ kinetics: Kinetics) {

        }

        @inlinable
        internal init(links: [EdgeID<Int>]) {
            self.links = links
        }
    }
}