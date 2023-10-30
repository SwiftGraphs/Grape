//
//  Simulation.swift
//
//
//  Created by li3zhen1 on 10/16/23.
//

#if canImport(simd)


import simd

enum Simulation3DError: Error {
    case subscriptionToNonexistentNode
}

/// A 3-Dimensional force simulation running on `float` and `simd_float3` types.
public final class Simulation3D<NodeID>
where NodeID: Hashable{

    public typealias V = simd_float3

    /// The type of the vector used in the simulation.
    /// Usually this is `Scalar` if you are on Apple platforms.
    public typealias Scalar = V.Scalar

    public let initializedAlpha: Scalar

    public var alpha: Scalar
    public var alphaMin: Scalar
    public var alphaDecay: Scalar
    public var alphaTarget: Scalar

    public var velocityDecay: Scalar

    public internal(set) var forces: [any ForceLike] = []

    /// The position of points stored in simulation.
    /// Ordered as the nodeIds you passed in when initializing simulation.
    /// They are always updated.
    public internal(set) var nodePositions: [V]

    /// The velocities of points stored in simulation.
    /// Ordered as the nodeIds you passed in when initializing simulation.
    /// They are always updated.
    public internal(set) var nodeVelocities: [V]

    /// The fixed positions of points stored in simulation.
    /// Ordered as the nodeIds you passed in when initializing simulation.
    /// They are always updated.
    public internal(set) var nodeFixations: [V?]

    public private(set) var nodeIds: [NodeID]

    @usableFromInline internal private(set) var nodeIdToIndexLookup: [NodeID: Int] = [:]

    /// Create a new simulation.
    /// - Parameters:
    ///   - nodeIds: Hashable identifiers for the nodes. Force simulation calculate them by order once created.
    ///   - alpha:
    ///   - alphaMin:
    ///   - alphaDecay: The larger the value, the faster the simulation converges to the final result.
    ///   - alphaTarget:
    ///   - velocityDecay:
    ///   - getInitialPosition: The closure to set the initial position of the node. If not provided, the initial position is set to zero.
    public init(
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
    public func getIndex(of nodeId: NodeID) -> Int {
        return nodeIdToIndexLookup[nodeId]!
    }

    /// Reset the alpha. The points will move faster as alpha gets larger.
    public func resetAlpha(_ alpha: Scalar) {
        self.alpha = alpha
    }

    /// Run the simulation for a number of iterations.
    /// Goes through all the forces created.
    /// The forces will call  `apply` then the positions and velocities will be modified.
    /// - Parameter iterationCount: Default to 1.
    public func tick(iterationCount: UInt = 1) {
        for _ in 0..<iterationCount {
            alpha += (alphaTarget - alpha) * alphaDecay

            for f in forces {
                f.apply()
            }

            for i in nodePositions.indices {
                if let fixation = nodeFixations[i] {
                    nodePositions[i] = fixation
                } else {
                    nodeVelocities[i] *= velocityDecay
                    nodePositions[i] += nodeVelocities[i]
                }
            }

        }
    }
}

#endif