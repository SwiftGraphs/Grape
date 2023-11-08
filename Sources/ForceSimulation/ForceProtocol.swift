public protocol ForceProtocol<Vector>{
    associatedtype Vector where Vector: SimulatableVector & L2NormCalculatable
    @inlinable func apply()
    @inlinable mutating func bindKinetics(_ kinetics: Kinetics<Vector>) 
}



public protocol ForceField<Vector>: ForceProtocol where Vector: SimulatableVector & L2NormCalculatable {
    associatedtype F: ForceProtocol<Vector> where F.Vector == Vector

    @inlinable
    @ForceBuilder<Vector> 
    var force: F { get set }
}

public extension ForceField {
    @inlinable 
    func apply() {
        self.force.apply()
    }

    @inlinable 
    mutating func bindKinetics(_ kinetics: Kinetics<Vector>) {
        self.force.bindKinetics(kinetics)
    }
}
