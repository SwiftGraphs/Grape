//
//  File.swift
//  
//
//  Created by li3zhen1 on 10/1/23.
//

import QuadTree
import simd


enum ManyBodyForceError: Error {
    case buildQuadTreeBeforeSimulationInitialized
}

extension SimulationNode: HasMassLikeProperty {
    public var property: Float {1.0}
}

public class ManyBodyForce<N> : Force where N : Identifiable {
    
    var strength: Float = -20
    
    public enum NodeMass {
        case constant(Float)
        case varied( (N.ID) -> Float )
    }
    var mass: NodeMass = .constant(1.0)

    weak var simulation: Simulation<N>?

    var theta2: Float = 0.001
    var theta: Float { theta2.squareRoot() }

    var distanceMin2: Float = 0.1
    var distanceMax2: Float = Float.infinity

    internal init(strength: Float) {
        self.strength = strength
    }

    public func apply(alpha: Float) {
        guard let simulation, 
              let forces = try? calculateForce(alpha: alpha) else { return }
        
        for i in simulation.simulationNodes.indices {
            simulation.updateNode(index: i) { n in
                n.velocity += forces[i]
            }
        }
    }

    public func initialize() {
        
    }
    
    func calculateForce(alpha: Float) throws -> [Vector2f] {
        
        guard let sim = self.simulation else {
            throw ManyBodyForceError.buildQuadTreeBeforeSimulationInitialized
        }
        
        let quad = try QuadTree(nodes: sim.simulationNodes.map { ($0, $0.position) })
        
        var forces = Array<Vector2f>(repeating: .zero, count: sim.simulationNodes.count)
        
        for i in sim.simulationNodes.indices {
            quad.visit { quadNode in
                if let centroid = quadNode.centroid {
                    let vec = centroid - sim.simulationNodes[i].position
                    
                    var distanceSquared = vec.jiggled()
                                             .lengthSquared()
                    
                    
                    // too far away, omit
                    guard distanceSquared < self.distanceMax2 else { return false }
                    
                    
                    // too close, enlarge distance
                    if distanceSquared < self.distanceMin2 {
                        distanceSquared = sqrt(self.distanceMin2 * distanceSquared)
                    }
                    
                    
                    if quadNode.isLeaf || distanceSquared * self.theta2 > quadNode.quad.area {
                        
                        forces[i] += self.strength * alpha * quadNode.accumulatedProperty * vec / pow(distanceSquared, 1.5)
                        
                        return false
                    }
                    else {
                        return true
                    }
                }
                else {
                    // it's empty here, no need to visit
                    return false
                }
            }
        }
        
        return forces
    }
    
}




extension Simulation {
    
    @discardableResult
    public func createManyBodyForce(
        name: String,
        strength: Float
    ) -> ManyBodyForce<N> {
        let manyBodyForce = ManyBodyForce<N>(strength: strength)
        manyBodyForce.simulation = self
        self.forces[name] = manyBodyForce
        return manyBodyForce
    }

}
