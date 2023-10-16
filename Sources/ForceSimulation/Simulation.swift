//
//  Simulation.swift
//
//
//  Created by li3zhen1 on 10/16/23.
//

import NDTree


enum SimulationError: Error {
    case subscriptionToNonexistentNode
}


public final class Simulation<NodeID, V> where NodeID: Hashable, V: VectorLike, V.Scalar == Double {
    public typealias Scalar = V.Scalar
    public struct NodeStatus {
        var position: V
        var velocity: V
        var fixation: V?
        
        static var zero: NodeStatus { .init(position: .zero, velocity: .zero) }
    }
    
    public let initializedAlpha: Double

    public var alpha: Double
    public var alphaMin: Double
    public var alphaDecay: Double
    public var alphaTarget: Double
    public var velocityDecay: V.Scalar
    
    public internal(set) var forces: [any ForceLike] = []

    public internal(set) var nodes: [NodeStatus]
    public private(set) var nodeIds: [NodeID]
    
    @usableFromInline internal private(set) var nodeIdToIndexLookup: [NodeID: Int] = [:]
    
    public init(
        nodeIds: [NodeID],
        alpha: Double = 1,
        alphaMin: Double = 1e-3,
        alphaDecay: Double = 5e-3,
        alphaTarget: Double = 0.0,
        velocityDecay: Double = 0.6,

        setInitialStatus getInitialStatus: (
            (NodeID) -> NodeStatus
        )? = nil
        
    ) {
        
        self.alpha = alpha
        self.initializedAlpha = alpha  // record and reload this when restarted

        self.alphaMin = alphaMin
        self.alphaDecay = alphaDecay
        self.alphaTarget = alphaTarget

        self.velocityDecay = velocityDecay
        
        
        if let getInitialStatus {
            self.nodes = nodeIds.map(getInitialStatus)
        }
        else {
            self.nodes = Array(repeating: .zero, count: nodeIds.count)
            for i in nodes.indices {
                nodes[i].jiggle()
            }
        }
        
        self.nodeIdToIndexLookup.reserveCapacity(nodeIds.count)
        for i in nodeIds.indices {
            self.nodeIdToIndexLookup[ nodeIds[i] ] = i
        }
        self.nodeIds = nodeIds
        
    }
    
    
    @inlinable internal func getIndex(of nodeId: NodeID) -> Int{
        return nodeIdToIndexLookup[ nodeId ]!
    }
    
    
    
    public func tick(iterationCount: UInt = 1) {
        for _ in 0..<iterationCount {
            alpha += (alphaTarget - alpha) * alphaDecay

            for f in forces {
                f.apply(alpha: alpha)
            }

            for i in nodes.indices {
                if let fixation = nodes[i].fixation {
                    nodes[i].position = fixation
                } else {
                    nodes[i].velocity *= velocityDecay
                    nodes[i].position += nodes[i].velocity
                }
            }

        }
    }
}


extension Simulation.NodeStatus {
    mutating func jiggle() {
        self.position = position.jiggled()
    }
}

