/// A force that chains two forces.
/// This is a helper for creating a strong-typed set of forces.
public struct ForceTuple<NodeID, V, F1, F2>: ForceProtocol
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

    @usableFromInline let f1: F1
    @usableFromInline let f2: F2
    @inlinable public func apply() {
        f1.apply()
        f2.apply()
    }
    @inlinable public init(_ f1: F1, _ f2: F2) {
        self.f1 = f1
        self.f2 = f2
    }

    @inlinable public func tupledWith<F>(_ another: F) -> some ForceProtocol where F: ForceProtocol, F.NodeID == NodeID, F.V == V {
        return ForceTuple<NodeID, V, Self, F>(self, another)
    }

}

extension ForceTuple: CustomDebugStringConvertible {
    @inlinable public var debugDescription: String {
        return "\(f1)\n\n\(f2)"
    }
}
