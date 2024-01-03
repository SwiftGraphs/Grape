import ForceSimulation
import simd

public struct CenterForce: ForceDescriptor {
    public var x: Double
    public var y: Double
    public var strength: Double
    @inlinable
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

}

extension Kinetics.CenterForce where Vector == SIMD2<Double> {
    @inlinable
    public init(descriptor: CenterForce) {
        self.init(center: [descriptor.x, descriptor.y], strength: descriptor.strength)
    }
}

public struct ManyBodyForce: ForceDescriptor {

    public var strength: Double
    public var mass: Kinetics2D.NodeMass
    public var theta: Double
    @inlinable
    public init(
        strength: Double = -30.0,
        mass: Kinetics2D.NodeMass = .constant(1.0),
        theta: Double = 0.9
    ) {
        self.strength = strength
        self.mass = mass
        self.theta = theta
    }
    @inlinable
    public func createForce() -> Kinetics2D.ManyBodyForce {
        return .init(strength: self.strength, nodeMass: self.mass, theta: theta)
    }

}

public struct LinkForce: ForceDescriptor {
    public var stiffness: Kinetics2D.LinkStiffness
    public var originalLength: Kinetics2D.LinkLength
    public var iterationsPerTick: UInt
    @usableFromInline var links: [EdgeID<Int>]
    @inlinable
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
    @inlinable
    public func createForce() -> Kinetics2D.LinkForce {
        return .init(
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
@inlinable
    public func createForce() -> Kinetics2D.CollideForce {
        return .init(
            radius: radius, strength: strength, iterationsPerTick: iterationsPerTick
        )
    }
@inlinable
    public init(
        strength: Double = 0.5,
        radius: Kinetics2D.CollideRadius = .constant(3.0),
        iterationsPerTick: UInt = 1
    ) {
        self.strength = strength
        self.radius = radius
        self.iterationsPerTick = iterationsPerTick
    }

    // public func attachToSimulation(_ simulation: Simulation2D<Int>) {
    //     simulation.createCollideForce(radius: radius, strength: strength, iterationsPerTick: iterationsPerTick)
    // }
}

public struct PositionForce: ForceDescriptor {

    public var strength: Kinetics2D.PositionStrength
    public var targetOnDirection: Kinetics2D.TargetOnDirection
    public var direction: Kinetics2D.DirectionOfPositionForce
@inlinable
    public init(
        direction: Kinetics2D.DirectionOfPositionForce,
        targetOnDirection: Kinetics2D.TargetOnDirection,
        strength: Kinetics2D.PositionStrength = .constant(1.0)
    ) {
        self.strength = strength
        self.direction = direction
        self.targetOnDirection = targetOnDirection
    }
@inlinable
    public func createForce() -> Kinetics2D.PositionForce {
        return .init(
            direction: direction,
            targetOnDirection: targetOnDirection,
            strength: strength
        )
    }
}

public struct RadialForce: ForceDescriptor {
    public var strength: Kinetics2D.RadialStrength
    public var radius: Kinetics2D.CollideRadius = .constant(3.0)
    public var center: SIMD2<Double> = .zero
    public var iterationsPerTick: UInt = 1
@inlinable
    public init(
        center: SIMD2<Double> = .zero,
        strength: Kinetics2D.RadialStrength = .constant(1.0),
        radius: Kinetics2D.CollideRadius = .constant(3.0),
        iterationsPerTick: UInt = 1
    ) {
        self.center = center
        self.strength = strength
        self.radius = radius
        self.iterationsPerTick = iterationsPerTick
    }
@inlinable
    public func createForce() -> Kinetics2D.RadialForce {
        return .init(center: center, radius: radius, strength: strength)
    }
}
