
/// A protocol that represents a force.
///
/// A force takes a simulation state and modifies its node positions and velocities.
public protocol ForceProtocol<Vector> {
    associatedtype Vector where Vector: SimulatableVector & L2NormCalculatable

    /// Takes a simulation state and modifies its node positions and velocities.
    /// This is executed in each tick of the simulation.
    @inlinable func apply()

    /// Bind to a kinetic system that describes the state of all nodes in your simulation.
    /// This has to be called before `apply` is called.
    @inlinable mutating func bindKinetics(_ kinetics: Kinetics<Vector>)
}

public protocol Force2D: ForceProtocol where Vector == SIMD2<Double> {}
public protocol Force3D: ForceProtocol where Vector == SIMD3<Float> {}

extension Kinetics2D.LinkForce: Force2D {}
extension Kinetics2D.ManyBodyForce: Force2D {}
extension Kinetics2D.CenterForce: Force2D {}
extension Kinetics2D.CollideForce: Force2D {}
extension Kinetics2D.PositionForce: Force2D {}
extension Kinetics2D.RadialForce: Force2D {}
extension Kinetics2D.EmptyForce: Force2D {}
extension CompositedForce: Force2D where Vector == SIMD2<Double> {}


extension Kinetics3D.LinkForce: Force3D {}
extension Kinetics3D.ManyBodyForce: Force3D {}
extension Kinetics3D.CenterForce: Force3D {}
extension Kinetics3D.CollideForce: Force3D {}
extension Kinetics3D.PositionForce: Force3D {}
extension Kinetics3D.RadialForce: Force3D {}
extension Kinetics3D.EmptyForce: Force3D {}
extension CompositedForce: Force3D where Vector == SIMD3<Float> {}

public protocol ForceDescriptor {
    associatedtype ConcreteForce: ForceProtocol
    func createForce() -> ConcreteForce
}

/// A helper force for hiding long type signatures you composed with `CompositedForce`.
/// You can easily build a force with a result builder.
public protocol ForceField: ForceProtocol
where Vector: SimulatableVector & L2NormCalculatable {
    associatedtype F: ForceProtocol<Vector> where F.Vector == Vector

    @inlinable
    @ForceBuilder<Vector>
    var force: F { get set }
}

extension ForceField {
    @inlinable
    public func apply() {
        self.force.apply()
    }

    @inlinable
    public mutating func bindKinetics(_ kinetics: Kinetics<Vector>) {
        self.force.bindKinetics(kinetics)
    }
}


public protocol ForceField2D: ForceField & Force2D { }

public protocol ForceField3D: ForceField & Force3D { }