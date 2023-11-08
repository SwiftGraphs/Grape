import ForceSimulation
import simd

public protocol ForceDescriptor<ConcreteForce> {
    associatedtype ConcreteForce: ForceProtocol
    func createForce() -> ConcreteForce
    // func attachToSimulation<Vector>(_ simulation: Simulation<Vector>) where Vector: SimulatableVector & L2NormCalculatable
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

    public func createForce() -> Kinetics2D.CenterForce {
        return .init(center: [x, y], strength: strength)
    }
    // public func attachToSimulation(_ simulation: Simulation2D<Int>) {
    //     simulation.createCenterForce(center: [x, y], strength: strength)
    // }
}

public struct ManyBodyForce: ForceDescriptor {

    public var strength: Double
    public var mass: Kinetics2D.NodeMass
    public var theta: Double

    public init(
        strength: Double = -30.0,
        mass: Kinetics2D.NodeMass = .constant(1.0),
        theta: Double = 0.9
    ) {
        self.strength = strength
        self.mass = mass
        self.theta = theta
    }

    public func createForce() -> Kinetics2D.ManyBodyForce {
        return .init(strength: self.strength, nodeMass: self.mass, theta: theta)
    }

    // public func attachToSimulation(_ simulation: Simulation2D<Int>) {
    //     simulation.createManyBodyForce(strength: strength, nodeMass: mass)
    // }
}

public struct LinkForce: ForceDescriptor {
    public var stiffness: Kinetics2D.LinkStiffness
    public var originalLength: Kinetics2D.LinkLength
    public var iterationsPerTick: UInt
    @usableFromInline var links: [EdgeID<Int>]

    public init(
        originalLength: Kinetics2D.LinkLength = .constant(30.0),
        stiffness: Kinetics2D.LinkStiffness = .weightedByDegree { _, _ in 1.0 },
        iterationsPerTick: UInt = 1
    ) {
        self.stiffness = stiffness
        self.originalLength = originalLength
        self.iterationsPerTick = iterationsPerTick
        self.links = []
    }
    public func createForce() -> Kinetics2D.LinkForce {
        return .init(
            links,
            stiffness: stiffness, originalLength: originalLength,
            iterationsPerTick: iterationsPerTick)
    }
    // public func attachToSimulation(_ simulation: Simulation2D<Int>) {
    //     simulation.createLinkForce(links, stiffness: stiffness, originalLength: originalLength, iterationsPerTick: iterationsPerTick)
    // }
}

public struct CollideForce: ForceDescriptor {
    public var strength: Double
    public var radius: Kinetics2D.CollideRadius = .constant(3.0)
    public var iterationsPerTick: UInt = 1

    public func createForce() -> Kinetics2D.CollideForce {
        return .init(
            radius: radius, strength: strength, iterationsPerTick: iterationsPerTick
        )
    }

    // public func attachToSimulation(_ simulation: Simulation2D<Int>) {
    //     simulation.createCollideForce(radius: radius, strength: strength, iterationsPerTick: iterationsPerTick)
    // }
}

public struct PositionForce: ForceDescriptor {

    public var strength: Kinetics2D.PositionStrength
    public var targetOnDirection: Kinetics2D.TargetOnDirection
    public var direction: Kinetics2D.DirectionOfPositionForce

    public init(
        direction: Kinetics2D.DirectionOfPositionForce,
        targetOnDirection: Kinetics2D.TargetOnDirection,
        strength: Kinetics2D.PositionStrength = .constant(1.0)
    ) {
        self.strength = strength
        self.direction = direction
        self.targetOnDirection = targetOnDirection
    }
    
    public func createForce() -> Kinetics2D.PositionForce {
        return .init(
            direction: direction,
            targetOnDirection: targetOnDirection,
            strength: strength
        )
    }
}
