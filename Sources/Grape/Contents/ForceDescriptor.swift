import ForceSimulation
import simd

public protocol ForceDescriptor {
    func attachToSimulation(_ simulation: Simulation2D<Int>)
}

public struct ForceSet {
    public let forces: [ForceDescriptor]
}

public struct CenterForce: ForceDescriptor {
    public var x: Double
    public var y: Double
    public var strength: Double

    public init(
        x: Double = 0.0,
        y: Double = 0.0,
        strength: Double = 0.5
    ) {
        self.x = x
        self.y = y
        self.strength = strength
    }

    public func attachToSimulation(_ simulation: Simulation2D<Int>) {
        simulation.createCenterForce(center: [x, y], strength: strength)
    }
}

public struct ManyBodyForce: ForceDescriptor {

    public var strength: Double
    public var mass: Simulation2D<Int>.ManyBodyForce.NodeMass

    public init(
        strength: Double = -30.0,
        mass: Simulation2D<Int>.ManyBodyForce.NodeMass = .constant(1.0)
    ) {
        self.strength = strength
        self.mass = mass
    }

    public func attachToSimulation(_ simulation: Simulation2D<Int>) {
        simulation.createManyBodyForce(strength: strength, nodeMass: mass)
    }
}

public struct LinkForce: ForceDescriptor {
    public var stiffness: Simulation2D<Int>.LinkForce.LinkStiffness
    public var originalLength: Simulation2D<Int>.LinkForce.LinkLength
    public var iterationsPerTick: UInt
    @usableFromInline var links: [EdgeID<Int>]

    public init(
        originalLength: Simulation2D<Int>.LinkForce.LinkLength = .constant(30.0),
        stiffness: Simulation2D<Int>.LinkForce.LinkStiffness = .weightedByDegree { _, _ in 1.0 },
        iterationsPerTick: UInt = 1
    ) {
        self.stiffness = stiffness
        self.originalLength = originalLength
        self.iterationsPerTick = iterationsPerTick
        self.links = []
    }

    public func attachToSimulation(_ simulation: Simulation2D<Int>) {
        simulation.createLinkForce(links, stiffness: stiffness, originalLength: originalLength, iterationsPerTick: iterationsPerTick)
    }
}

public struct CollideForce: ForceDescriptor {
    public var strength: Double
    public var radius: Simulation2D<Int>.CollideForce.CollideRadius = .constant(3.0)
    public var iterationsPerTick: UInt = 1

    public func attachToSimulation(_ simulation: Simulation2D<Int>) {
        simulation.createCollideForce(radius: radius, strength: strength, iterationsPerTick: iterationsPerTick)
    }
}

public struct DirectionForce: ForceDescriptor {

    public var strength: Simulation2D<Int>.DirectionForce2D.Strength
    public var targetOnDirection: Simulation2D<Int>.DirectionForce2D.TargetOnDirection
    public var direction: Simulation2D<Int>.DirectionForce2D.Direction

    public init(
        direction: Simulation2D<Int>.DirectionForce2D.Direction,
        targetOnDirection: Simulation2D<Int>.DirectionForce2D.TargetOnDirection,
        strength: Simulation2D<Int>.DirectionForce2D.Strength = .constant(1.0)
    ) {
        self.strength = strength
        self.direction = direction
        self.targetOnDirection = targetOnDirection
    }

    public func attachToSimulation(_ simulation: Simulation2D<Int>) {
        simulation.createPositionForce(direction: direction, targetOnDirection: targetOnDirection, strength: strength)
    }
}
