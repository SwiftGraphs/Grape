extension Force {

    /// A force that chains two forces.
    /// This is a helper for creating a strong-typed set of forces.
    /// TODO: replace with generic packing
    public struct ForceField<NodeID, V, F1, F2>: ForceProtocol
    where
        F1: ForceProtocol, F2: ForceProtocol, NodeID: Hashable, V: VectorLike,
        V.Scalar: SimulatableFloatingPoint, F1.NodeID == NodeID, F2.NodeID == NodeID, F1.V == V,
        F2.V == V
    {
        @inlinable
        public func bindSimulation(_ simulation: SimulationState<NodeID, V>?) {
            //        f1.bindSimulation(simulation)
            f2.bindSimulation(simulation)
        }

        @usableFromInline let f1: F1?
        @usableFromInline let f2: F2
        @inlinable public func apply() {
            f1?.apply()
            f2.apply()
        }
        @inlinable public init(_ f1: F1, _ f2: F2) {
            self.f1 = f1
            self.f2 = f2
        }

        @inlinable public func tupledWith<F>(_ another: F) -> some ForceProtocol
        where F: ForceProtocol, F.NodeID == NodeID, F.V == V {
            return ForceField<NodeID, V, Self, F>(self, another)
        }

        @inlinable
        public init(@ForceBuilder<NodeID, V> _ builder: () -> ForceField) {
            let force = builder()
            self.f1 = nil
            self.f2 = force.f2
        }
    }

}

@resultBuilder
public struct ForceBuilder<NodeID, V>
where NodeID: Hashable, V: VectorLike, V.Scalar: SimulatableFloatingPoint {

    @inlinable
    public static func buildPartialBlock<T: ForceProtocol>(first: T)
        -> Force.ForceField<
            NodeID, V, Force.EmptyForce<NodeID, V>, T
        >
    where T.NodeID == NodeID, T.V == V {
        return Force.ForceField<NodeID, V, _, T>(Force.EmptyForce(), first)
    }

    @inlinable
    public static func buildPartialBlock<T1: ForceProtocol, T2: ForceProtocol>(
        accumulated: T1, next: T2
    ) -> Force.ForceField<NodeID, V, T1, T2>
    where T1.NodeID == T2.NodeID, T1.V == T2.V, T1.NodeID == NodeID, T1.V == V {
        return Force.ForceField<NodeID, V, T1, T2>(accumulated, next)
    }

    @inlinable
    public static func buildBlock()
        -> Force.ForceField<NodeID, V, Force.EmptyForce<NodeID, V>, Force.EmptyForce<NodeID, V>>
    {
        return Force.ForceField<
            NodeID, V, Force.EmptyForce<NodeID, V>, Force.EmptyForce<NodeID, V>
        >(Force.EmptyForce(), Force.EmptyForce())
    }
}
