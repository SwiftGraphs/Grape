//
//  CollideForce.swift
//
//
//  Created by li3zhen1 on 10/1/23.
//

import QuadTree

enum CollideForceError: Error {
    case applyBeforeSimulationInitialized
    case maxRadiusCannotBeCalculatedAfterRemoval
}

/// A delegate for finding the maximum radius (of nodes) in a quad.
public struct MaxRadiusQuadTreeDelegate<N>: QuadDelegate where N: Identifiable {

    public typealias Node = N

    public var maxNodeRadius: Float

    @usableFromInline var radiusProvider: (N.ID) -> Float

    init(
        radiusProvider: @escaping (N.ID) -> Float
    ) {
        self.radiusProvider = radiusProvider
        self.maxNodeRadius = 0.0
    }

    internal init(
        initialMaxNodeRadius: Float = 0.0,
        radiusProvider: @escaping (N.ID) -> Float
    ) {
        self.maxNodeRadius = initialMaxNodeRadius
        self.radiusProvider = radiusProvider
    }

    @inlinable public mutating func didAddNode(_ node: N, at position: Vector2f) {
        let p = radiusProvider(node.id)
        maxNodeRadius = max(maxNodeRadius, p)
    }

    @inlinable public mutating func didRemoveNode(_ node: N, at position: Vector2f) {
        if radiusProvider(node.id) >= maxNodeRadius {
            // 🤯 for Collide force, set to 0 is fine (?)
            maxNodeRadius = 0
        }
    }

    public func copy() -> Self {
        return Self(
            initialMaxNodeRadius: self.maxNodeRadius,
            radiusProvider: self.radiusProvider
        )
    }

    public func createNew() -> Self {
        return Self(
            radiusProvider: self.radiusProvider
        )
    }

}

final public class CollideForce<N> where N: Identifiable {
    var radius: CollideRadius
    var calculatedRadius: [N.ID: Float] = [:]

    var strength: Float

    let iterationsPerTick: Int

    weak var simulation: Simulation<N>? {
        didSet {
            guard let sim = self.simulation else { return }
            calculatedRadius = radius.calculated(sim.simulationNodes)
        }
    }

    internal init(
        radius: CollideRadius,
        strength: Float = 1.0,
        iterationsPerTick: Int = 1
    ) {
        self.radius = radius
        self.iterationsPerTick = iterationsPerTick
        self.strength = strength
    }
}

extension CollideForce {
    public enum CollideRadius {
        case constant(Float)
        case varied((N.ID) -> Float)
    }
}

extension CollideForce.CollideRadius {
    public func calculated<SimNode>(_ nodes: [SimNode]) -> [N.ID: Float]
    where SimNode: Identifiable, SimNode.ID == N.ID {
        switch self {
        case .constant(let r):
            return Dictionary(uniqueKeysWithValues: nodes.map { ($0.id, r) })
        case .varied(let r):
            return Dictionary(uniqueKeysWithValues: nodes.map { ($0.id, r($0.id)) })
        }
    }
}

extension CollideForce: Force {
    public func apply(alpha: Float) {
        guard let sim = self.simulation else { return }

        for _ in 0..<iterationsPerTick {
            guard
                let quad = try? QuadTree2(
                    nodes: sim.simulationNodes.map { ($0, $0.position) },
                    getQuadDelegate: {
                        MaxRadiusQuadTreeDelegate {
                            // switch self.radius {
                            // case .constant(let r):
                            //     return r
                            // case .varied(_):
                            //     return self.calculatedRadius[$0, default: 0.0]
                            // }
                            return self.calculatedRadius[$0, default: 0.0]
                            // return self.calculatedRadius[$0]!
                        }
                    }
                )
            else { return }

            for i in sim.simulationNodes.indices {
                let iNode = sim.simulationNodes[i]
                let iNodeId = iNode.id
                let iR = self.calculatedRadius[iNodeId]!
                let iR2 = iR * iR
                let iPosition = iNode.position + iNode.velocity

                quad.visit { quadNode in

                    let maxRadiusOfQuad = quadNode.quadDelegate.maxNodeRadius
                    let deltaR = maxRadiusOfQuad + iR

                    if !quadNode.nodes.isEmpty {
                        for jNodeId in quadNode.nodes.keys {
                            // is leaf, make sure every collision happens once.
                            guard let j = sim.nodeIndexLookup[jNodeId], j > i else { continue }
                            let jR = self.calculatedRadius[jNodeId]!
                            let jNode = sim.simulationNodes[j]
                            var deltaPosition = iPosition - (jNode.position + jNode.velocity)
                            let l = deltaPosition.lengthSquared()

                            let deltaR = iR + jR
                            if l < deltaR * deltaR {

                                var l = deltaPosition.jiggled().length()
                                l = (deltaR - l) / l * self.strength

                                let jR2 = jR * jR

                                let k = jR2 / (iR2 + jR2)

                                deltaPosition *= l

                                sim.simulationNodes[i].velocity += deltaPosition * k
                                sim.simulationNodes[j].velocity -= deltaPosition * (1 - k)
                            }
                        }
                        return false
                    }

                    return
                        !(quadNode.quad.x0 > iPosition.x + deltaR /* True if no overlap */
                        || quadNode.quad.x1 < iPosition.x - deltaR
                        || quadNode.quad.y0 > iPosition.y + deltaR
                        || quadNode.quad.y1 < iPosition.y - deltaR)
                }
            }
        }
    }
}

extension Simulation {
    @discardableResult
    public func createCollideForce(
        radius: CollideForce<N>.CollideRadius = .constant(3.0),
        strength: Float = 1.0,
        iterationsPerTick: Int = 1
    ) -> CollideForce<N> {
        let f = CollideForce<N>(
            radius: radius,
            strength: strength,
            iterationsPerTick: iterationsPerTick
        )
        f.simulation = self
        self.forces.append(f)
        return f
    }
}
