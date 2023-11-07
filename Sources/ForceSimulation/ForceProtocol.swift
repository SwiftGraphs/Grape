protocol ForceProtocol<Vector>{
    associatedtype Vector where Vector: SIMD, Vector.Scalar: FloatingPoint

    // var kinetics: Kinetics<Vector>? { get set }

    func apply()

    func bindKinetics(_ kinetics: Kinetics<Vector>) 
}


class CenterForce<Vector>: ForceProtocol where Vector: SIMD, Vector.Scalar: FloatingPoint {
    
    var kinetics: Kinetics<Vector>?

    func apply() {
    
    }

    func bindKinetics(_ kinetics: Kinetics<Vector>) {
        self.kinetics = kinetics
    }

}

struct CompositedForce<Vector, F1, F2>: ForceProtocol where Vector: SIMD, Vector.Scalar: FloatingPoint, F1: ForceProtocol<Vector>, F2: ForceProtocol<Vector> {
    let force1: F1?
    let force2: F2

    // var kinetics: Kinetics<Vector>?

    init(force1: F1? = nil, force2: F2) {
        self.force1 = force1
        self.force2 = force2
    }

    func apply() {
        self.force1?.apply()
        self.force2.apply()
    }

    func bindKinetics(_ kinetics: Kinetics<Vector>) {
        self.force1?.bindKinetics(kinetics)
        self.force2.bindKinetics(kinetics)
    }

}


protocol ForceField<Vector>: ForceProtocol where Vector: SIMD, Vector.Scalar: FloatingPoint {
    associatedtype InnerForce: ForceProtocol<Vector> where InnerForce.Vector == Vector
    var force: InnerForce { get }
}

extension ForceField {
    func apply() {
        self.force.apply()
    }

    func bindKinetics(_ kinetics: Kinetics<Vector>) {
        self.bindKinetics(kinetics)
    }
}