//
//  RadialForce.swift
//
//
//  Created by li3zhen1 on 10/1/23.
//
import QuadTree

final public class RadialForce<N>: Force where N: Identifiable {
    weak var simulation: Simulation<N>? {
        didSet {
            guard let sim = self.simulation else { return }
            self.calculatedStrength = strength.calculated(sim.simulationNodes)
            self.calculatedRadius = radius.calculated(sim.simulationNodes)
        }
    }

    public var center: Vector2f

    /// Radius accessor
    public enum Radius {
        case constant(Float)
        case varied([N.ID: Float])
    }
    public var radius: Radius
    private var calculatedRadius: [N.ID: Float] = [:]

    /// Strength accessor
    public enum Strength {
        case constant(Float)
        case varied([N.ID: Float])
    }
    public var strength: Strength
    private var calculatedStrength: [N.ID: Float] = [:]




    public init(center: Vector2f, radius: Radius, strength: Strength) {
        self.center = center
        self.radius = radius
        self.strength = strength
    }

    public func apply(alpha: Float) {
        guard let sim = self.simulation else { return }
        for i in sim.simulationNodes.indices {
            let nodeId = sim.simulationNodes[i].id
            let deltaPosition = (sim.simulationNodes[i].position - self.center).jiggled()
            let r = deltaPosition.length()
            let k =
                (self.calculatedRadius[nodeId, default: 0.0]
                    * self.calculatedStrength[nodeId, default: 0.0] * alpha) / r
            sim.simulationNodes[i].velocity += deltaPosition * k
        }
    }

}

extension RadialForce.Strength {
    public func calculated<SimNode>(_ nodes: [SimNode]) -> [N.ID: Float]
    where SimNode: Identifiable, SimNode.ID == N.ID {
        switch self {
        case .constant(let s):
            return Dictionary(uniqueKeysWithValues: nodes.map { ($0.id, s) })
        case .varied(let s):
            return s
        }
    }
}

extension RadialForce.Radius {
    public func calculated<SimNode>(_ nodes: [SimNode]) -> [N.ID: Float]
    where SimNode: Identifiable, SimNode.ID == N.ID {
        switch self {
        case .constant(let r):
            return Dictionary(uniqueKeysWithValues: nodes.map { ($0.id, r) })
        case .varied(let r):
            return r
        }
    }
}

extension Simulation {

    @discardableResult
    public func createRadialForce(
        center: Vector2f = .zero, 
        radius: RadialForce<N>.Radius = .constant(5.0),  
        strength: RadialForce<N>.Strength = .constant(0.1)
    ) -> RadialForce<N> {
        let f = RadialForce<N>(center: center, radius: radius, strength: strength)
        f.simulation = self
        self.forces.append(f)
        return f
    }

}
