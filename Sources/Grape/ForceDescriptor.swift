import ForceSimulation
import simd

public protocol ForceDescriptor {
    func attachToSimulation<NodeID>(_ simulation: Simulation2D<NodeID>)
}

public struct ForceField: ForceDescriptor {
    public let forces: [ForceDescriptor]

    public func attachToSimulation<NodeID>(_ simulation: Simulation2D<NodeID>) where NodeID : Hashable {
        for forceDescriptor in forces {
            forceDescriptor.attachToSimulation(simulation)
        }
    }
}

public struct CenterForce: ForceDescriptor {
    public var x: Double
    public var y: Double
    public var strength: Double

    public func attachToSimulation<NodeID>(_ simulation: Simulation2D<NodeID>) where NodeID : Hashable {
        simulation.createCenterForce(center: [x, y], strength: strength)
    }
}

public struct ManyBodyForce<NodeID: Hashable>: ForceDescriptor {
    
    public var strength: Double
    public var theta: Double
    public var distanceMin: Double
    public var distanceMax: Double

    public func attachToSimulation(_ simulation: Simulation2D<NodeID>) {
        simulation.createManyBodyForce(strength: strength, nodeMass: .)
    }
}

public struct LinkForce: ForceDescriptor {
    public var strength: Double
    public var distance: Double
    public var iterations: Int
}

public struct CollideForce: ForceDescriptor {
    public var strength: Double
    public var radius: Double
    public var iterations: Int
}

public struct DirectionForce: ForceDescriptor {
    public enum Dimension: Hashable {
        case x
        case y
    }
    public var strength: Double
    public var targetOnDirection: Double
    public var direction: DirectionForce.Dimension
}


