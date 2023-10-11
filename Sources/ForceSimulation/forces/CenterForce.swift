//
//  CenterForce.swift
//
//
//  Created by li3zhen1 on 10/1/23.
//

import QuadTree

final public class CenterForce<N>: Force where N: Identifiable {

    public var center: Vector2f
    public var strength: Double
    weak var simulation: Simulation<N>?

    internal init(center: Vector2f, strength: Double) {
        self.center = center
        self.strength = strength
    }

    internal init(x: Double, y: Double, strength: Double) {
        self.center = Vector2f(x, y)
        self.strength = strength
    }

    var x: Double {
        get { return center.x }
        set { self.center.x = newValue }
    }
    var y: Double {
        get { return center.y }
        set { self.center.y = newValue }
    }

    public func apply(alpha: Double) {
        guard let sim = self.simulation else { return }

        var meanPosition = Vector2f.zero
        for n in sim.simulationNodes {
            meanPosition += n.position
        }
        let delta = meanPosition * (self.strength / Double(sim.simulationNodes.count))

        for i in sim.simulationNodes.indices {
            sim.simulationNodes[i].position -= delta
        }
    }

}

extension Simulation {

    @discardableResult
    public func createCenterForce(x: Double, y: Double, strength: Double = 0.1) -> CenterForce<N> {
        let f = CenterForce<N>(x: x, y: y, strength: strength)
        f.simulation = self
        self.forces.append(f)
        return f
    }

    @discardableResult
    public func createCenterForce(center: Vector2f, strength: Double = 0.1) -> CenterForce<N> {
        let f = CenterForce<N>(center: center, strength: strength)
        f.simulation = self
        self.forces.append(f)
        return f
    }

}
