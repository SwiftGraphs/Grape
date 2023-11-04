extension Dimension {

    public typealias Field = PackedForce

    public struct PackedForce<F1, F2>: ForceProtocol
    where
        F1: ForceProtocol, F2: ForceProtocol,
        F1.NodeID == F2.NodeID,
        F1.NodeID == F2.NodeID,
        NodeID == F1.NodeID,
        NodeID == F2.NodeID,
        V == F1.V,
        V == F2.V
    {
        public typealias NodeID = F1.NodeID

        public typealias V = F1.V

        let left: F1?
        let right: F2

        init(left: F1, right: F2) {
            self.left = left
            self.right = right
        }

        init(@ForceBuilder _ buildField: () -> PackedForce<F1, F2>) {
            let result = buildField()
            self.left = result.left
            self.right = result.right
        }

        public func apply(){
            left?.apply()
            right.apply()
        }

        public func bind<S: SimulationProtocol>(_ simulation: S)
        where S.NodeID == NodeID, S.V == V {
            right.bind(simulation)
        }
    }
}

extension Dimension.PackedForce where F1 == Dimension.EmptyForce {
    init(_ right: F2) {
        self.left = nil
        self.right = right
    }
}
