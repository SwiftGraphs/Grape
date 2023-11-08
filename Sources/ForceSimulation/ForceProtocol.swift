public protocol ForceProtocol<Vector>{
    associatedtype Vector where Vector: SimulatableVector & L2NormCalculatable

    // var kinetics: Kinetics<Vector>? { get set }

    @inlinable func apply()

    @inlinable func bindKinetics(_ kinetics: Kinetics<Vector>) 
}



public protocol ForceField<Vector>: ForceProtocol where Vector: SimulatableVector & L2NormCalculatable {
    associatedtype F: ForceProtocol<Vector> where F.Vector == Vector

    @inlinable
    @ForceBuilder<Vector> 
    var force: F { get }
}

public extension ForceField {
    @inlinable 
    func apply() {
        self.force.apply()
    }

    @inlinable 
    func bindKinetics(_ kinetics: Kinetics<Vector>) {
        self.force.bindKinetics(kinetics)
    }
}
