//
//  Simulation.swift
//
//
//  Created by li3zhen1 on 10/16/23.
//

/// Data store for the simulation.
public final class SimulationState<NodeID, V>
where NodeID: Hashable, V: VectorLike, V.Scalar: SimulatableFloatingPoint {

    /// The type of the vector used in the simulation.
    /// Usually this is `Scalar` if you are on Apple platforms.
    public typealias Scalar = V.Scalar

    public let initializedAlpha: Scalar

    public var alpha: Scalar
    public var alphaMin: Scalar
    public var alphaDecay: Scalar
    public var alphaTarget: Scalar

    public var velocityDecay: Scalar

    // @usableFromInline var forces: ForceField

    /// The position of points stored in simulation.
    /// Ordered as the nodeIds you passed in when initializing simulation.
    /// They are always updated.
    @usableFromInline var nodePositions: [V]

    @inlinable public var nodePositisions: [V] {
        return self.nodePositions
    }

    /// The velocities of points stored in simulation.
    /// Ordered as the nodeIds you passed in when initializing simulation.
    /// They are always updated.
    @usableFromInline var nodeVelocities: [V]

    /// The fixed positions of points stored in simulation.
    /// Ordered as the nodeIds you passed in when initializing simulation.
    /// They are always updated.
    @usableFromInline var nodeFixations: [V?]

    @usableFromInline var nodeIds: [NodeID]

    @usableFromInline var nodeIdToIndexLookup: [NodeID: Int] = [:]

    /// Create a new simulation.
    /// 
    /// - Parameters:
    ///   - nodeIds: Hashable identifiers for the nodes. Force simulation calculate them by order once created.
    ///   - alpha:
    ///   - alphaMin:
    ///   - alphaDecay: The larger the value, the faster the simulation converges to the final result.
    ///   - alphaTarget:
    ///   - velocityDecay:
    ///   - getInitialPosition: The closure to set the initial position of the node. If not provided, the initial position is set to zero.
    @inlinable public init(
        nodeIds: [NodeID],
        alpha: Scalar = 1,
        alphaMin: Scalar = 1e-3,
        alphaDecay: Scalar = 2e-3,
        alphaTarget: Scalar = 0.0,
        velocityDecay: Scalar = 0.6,

        setInitialStatus getInitialPosition: (
            (NodeID) -> V
        )? = nil

    ) {

        self.alpha = alpha
        self.initializedAlpha = alpha  // record and reload this when restarted

        self.alphaMin = alphaMin
        self.alphaDecay = alphaDecay
        self.alphaTarget = alphaTarget

        self.velocityDecay = velocityDecay
        // self.forces = forceField

        if let getInitialPosition {
            self.nodePositions = nodeIds.map(getInitialPosition)
        } else {
            self.nodePositions = Array(repeating: .zero, count: nodeIds.count)
        }

        self.nodeVelocities = Array(repeating: .zero, count: nodeIds.count)
        self.nodeFixations = Array(repeating: nil, count: nodeIds.count)

        self.nodeIdToIndexLookup.reserveCapacity(nodeIds.count)
        for i in nodeIds.indices {
            self.nodeIdToIndexLookup[nodeIds[i]] = i
        }
        self.nodeIds = nodeIds

    }

    /// Get the index in the nodeArray for `nodeId`
    /// - **Complexity**: O(1)
    @inlinable
    public func getIndex(of nodeId: NodeID) -> Int {
        return nodeIdToIndexLookup[nodeId]!
    }

    /// Reset the alpha. The points will move faster as alpha gets larger.
    @inlinable
    public func resetAlpha(_ alpha: Scalar) {
        self.alpha = alpha
    }
}
