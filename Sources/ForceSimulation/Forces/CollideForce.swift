
public struct MaxRadiusTreeDelegate<NodeID, V>: NDTreeDelegate where NodeID: Hashable, V: VectorLike {

    public var maxNodeRadius: V.Scalar

    @usableFromInline var radiusProvider: (NodeID) -> V.Scalar

    @inlinable
    public mutating func didAddNode(_ nodeId: NodeID, at position: V) {
        let p = radiusProvider(nodeId)
        maxNodeRadius = max(maxNodeRadius, p)
    }

    @inlinable
    public mutating func didRemoveNode(_ nodeId: NodeID, at position: V) {
        if radiusProvider(nodeId) >= maxNodeRadius {
            // 🤯 for Collide force, set to 0 is fine
            // Otherwise you need to traverse the delegate again
            maxNodeRadius = 0
        }
    }

    @inlinable
    public func copy() -> MaxRadiusTreeDelegate<NodeID, V> {
        return Self(maxNodeRadius: maxNodeRadius, radiusProvider: radiusProvider)
    }

    @inlinable
    public func spawn() -> MaxRadiusTreeDelegate<NodeID, V> {
        return Self(radiusProvider: radiusProvider)
    }

    @inlinable init(maxNodeRadius: V.Scalar = 0, radiusProvider: @escaping (NodeID) -> V.Scalar) {
        self.maxNodeRadius = maxNodeRadius
        self.radiusProvider = radiusProvider
    }

}


/// A force that prevents nodes from overlapping.
/// This is a very expensive force, the complexity is `O(n log(n))`,
/// where `n` is the number of nodes.
/// See [Collide Force - D3](https://d3js.org/d3-force/collide).
public final class CollideForce<NodeID, V>: ForceProtocol
where NodeID: Hashable, V: VectorLike, V.Scalar: SimulatableFloatingPoint {
    @inlinable public func bindSimulation(_ simulation: SimulationState<NodeID, V>?) {
        self.simulation = simulation
        guard let sim = simulation else { return }
        self.calculatedRadius = radius.calculated(for: sim)
    }


    @usableFromInline weak var simulation: SimulationState<NodeID, V>?

    public enum CollideRadius {
        case constant(V.Scalar)
        case varied((NodeID) -> V.Scalar)
    }
    public var radius: CollideRadius
    @usableFromInline var calculatedRadius: [V.Scalar] = []

    public let iterationsPerTick: UInt
    public var strength: V.Scalar

    @inlinable internal init(
        radius: CollideRadius,
        strength: V.Scalar = 1.0,
        iterationsPerTick: UInt = 1
    ) {
        self.radius = radius
        self.iterationsPerTick = iterationsPerTick
        self.strength = strength
    }

    @inlinable public func apply() {
        guard let sim = self.simulation else { return }
        

        for _ in 0..<iterationsPerTick {

            let coveringBox = NDBox<V>.cover(of: sim.nodePositions)

            let clusterDistance: V.Scalar = V.Scalar(Int(0.00001))

            let tree = NDTree<V, MaxRadiusTreeDelegate<Int, V>>(
                box: coveringBox, clusterDistance: clusterDistance
            ) {
                return switch self.radius {
                case .constant(let m):
                    MaxRadiusTreeDelegate<Int, V> { _ in m }
                case .varied(_):
                    MaxRadiusTreeDelegate<Int, V> { index in
                        self.calculatedRadius[index]
                    }
                }
            }

            for i in sim.nodePositions.indices {
                tree.add(i, at: sim.nodePositions[i])
            }

            for i in sim.nodePositions.indices {
                let iOriginalPosition = sim.nodePositions[i]
                let iOriginalVelocity = sim.nodeVelocities[i]
                let iR = self.calculatedRadius[i]
                let iR2 = iR * iR
                let iPosition = iOriginalPosition + iOriginalVelocity

                tree.visit { t in

                    let maxRadiusOfQuad = t.delegate.maxNodeRadius
                    let deltaR = maxRadiusOfQuad + iR

                    if t.nodePosition != nil {
                        for j in t.nodeIndices {
                            //                            print("\(i)<=>\(j)")
                            // is leaf, make sure every collision happens once.
                            guard j > i else { continue }

                            let jR = self.calculatedRadius[j]
                            let jOriginalPosition = sim.nodePositions[j]
                            let jOriginalVelocity = sim.nodeVelocities[j]
                            var deltaPosition =
                                iPosition - (jOriginalPosition + jOriginalVelocity)
                            let l = deltaPosition.lengthSquared()

                            let deltaR = iR + jR
                            if l < deltaR * deltaR {

                                var l = deltaPosition.jiggled().length()
                                l = (deltaR - l) / l * self.strength

                                let jR2 = jR * jR

                                let k = jR2 / (iR2 + jR2)

                                deltaPosition *= l

                                sim.nodeVelocities[i] += deltaPosition * k
                                sim.nodeVelocities[j] -= deltaPosition * (1 - k)
                            }
                        }
                        return false
                    }

                    for laneIndex in t.box.p0.indices {
                        let _v = t.box.p0[laneIndex]
                        if _v > iPosition[laneIndex] + deltaR /* True if no overlap */ {
                            return false
                        }
                    }

                    for laneIndex in t.box.p1.indices {
                        let _v = t.box.p1[laneIndex]
                        if _v < iPosition[laneIndex] - deltaR /* True if no overlap */ {
                            return false
                        }
                    }
                    return true
                }
            }
        }
    }

}



extension CollideForce.CollideRadius {
    @inlinable public func calculated(for simulation: SimulationState<NodeID, V>) -> [V.Scalar] {
        switch self {
        case .constant(let r):
            return Array(repeating: r, count: simulation.nodePositions.count)
        case .varied(let radiusProvider):
            return simulation.nodeIds.map { radiusProvider($0) }
        }
    }
}



extension Simulation {
    @inlinable
    public func withCollideForce(
        radius: CollideForce<NodeID, V>.CollideRadius = .constant(3.0),
        strength: V.Scalar = 1.0,
        iterationsPerTick: UInt = 1
    ) -> Simulation<
        NodeID, V, ForceTuple<NodeID, V, F, CollideForce<NodeID, V>>
    > where F.NodeID == NodeID, F.V == V {
        let f = CollideForce<NodeID, V>(
            radius: radius,
            strength: strength,
            iterationsPerTick: iterationsPerTick
        )
//        f.bindSimulation(self.simulation)
        return with(f)
    }
}
