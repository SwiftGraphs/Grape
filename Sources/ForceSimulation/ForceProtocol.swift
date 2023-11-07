public protocol ForceProtocol<Vector>{
    associatedtype Vector where Vector: SimulatableVector & L2NormCalculatable

    // var kinetics: Kinetics<Vector>? { get set }

    func apply()

    func bindKinetics(_ kinetics: Kinetics<Vector>) 
}



protocol ForceField<Vector>: ForceProtocol where Vector: SimulatableVector & L2NormCalculatable {
    associatedtype F: ForceProtocol<Vector> where F.Vector == Vector
    var force: F { get }
}

extension ForceField {
    func apply() {
        self.force.apply()
    }

    func bindKinetics(_ kinetics: Kinetics<Vector>) {
        self.force.bindKinetics(kinetics)
    }
}
