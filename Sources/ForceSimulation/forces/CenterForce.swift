//
//  CenterForce.swift
//
//
//  Created by li3zhen1 on 10/1/23.
//

import QuadTree

public class CenterForce<VID> : Force where VID : Hashable {

    public var center: Vector2f
    public var strength: Float
    weak var simulation: Simulation<VID>?
    
    internal init(center: Vector2f, strength: Float) {
        self.center = center
        self.strength = strength
    }
    
    internal init(x: Float, y: Float, strength: Float) {
        self.center = Vector2f(x, y)
        self.strength = strength
    }
    
    var x: Float {
        get { return center.x }
        set { self.center.x = newValue }
    }
    var y: Float {
        get { return center.y }
        set { self.center.y = newValue }
    }
    
    public func apply(alpha: Float) {
        guard let sim = self.simulation else { return }
        
        var meanPosition = Vector2f.zero
        for n in sim.simulationNodes {
            meanPosition += n.position
        }
        let delta = meanPosition * (self.strength / Float(sim.simulationNodes.count))

        for i in sim.simulationNodes.indices {
            sim.simulationNodes[i].position -= delta
        }
    }
    
    public func initialize() {
        
    }

}


extension Simulation{

    @discardableResult
    public func createCenterForce(x: Float, y: Float, strength: Float = 0.1, name: String = "center") -> CenterForce<NodeID> {
        let f = CenterForce<NodeID>(x: x, y: y, strength: strength)
        f.simulation = self
        self.forces[name] = f
        return f
    }
    
    @discardableResult
    public func createCenterForce(center: Vector2f, strength: Float = 0.1, name: String = "center") -> CenterForce<NodeID> {
        let f = CenterForce<NodeID>(center: center, strength: strength)
        f.simulation = self
        self.forces[name] = f
        return f
    }

}