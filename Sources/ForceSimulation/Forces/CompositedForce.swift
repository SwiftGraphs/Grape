/// Workaround for yet unsupported packed generic pack types & same type requirements
public struct CompositedForce<Vector, F1, F2>: ForceProtocol
where F1: ForceProtocol<Vector>, F2: ForceProtocol<Vector>, Vector: SimulatableVector & L2NormCalculatable
{

    @usableFromInline let force1: F1?
    @usableFromInline let force2: F2

    // var kinetics: Kinetics<Vector>?

    public init(_ force1: F1? = nil, _ force2: F2) {
        self.force1 = force1
        self.force2 = force2
    }

    public func apply() {
        self.force1?.apply()
        self.force2.apply()
    }

    public func bindKinetics(_ kinetics: Kinetics<Vector>) {
        self.force1?.bindKinetics(kinetics)
        self.force2.bindKinetics(kinetics)
    }

}
