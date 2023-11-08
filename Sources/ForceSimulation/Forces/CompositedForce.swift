/// Workaround for yet unsupported packed generic pack types & same type requirements
public struct CompositedForce<Vector, F1, F2>: ForceProtocol
where
    F1: ForceProtocol<Vector>, F2: ForceProtocol<Vector>,
    Vector: SimulatableVector & L2NormCalculatable
{

    @usableFromInline let force1: F1?
    @usableFromInline let force2: F2

    // var kinetics: Kinetics<Vector>?
    @inlinable
    public init(force1: F1? = nil, force2: F2) {
        self.force1 = force1
        self.force2 = force2
    }
    @inlinable
    public func apply() {
        self.force1?.apply()
        self.force2.apply()
    }
    @inlinable
    public func bindKinetics(_ kinetics: Kinetics<Vector>) {
        self.force1?.bindKinetics(kinetics)
        self.force2.bindKinetics(kinetics)
    }

    @inlinable
    public init(@ForceBuilder<Vector> _ builder: () -> CompositedForce<Vector, F1, F2>) {
        self = builder()
    }
}

@resultBuilder
public struct ForceBuilder<Vector>
where Vector: SimulatableVector & L2NormCalculatable {

    public static func buildPartialBlock<F>(first: F) ->  CompositedForce<Vector, Kinetics<Vector>.EmptyForce, F>
    where F: ForceProtocol<Vector>, Vector: SimulatableVector & L2NormCalculatable {
        return .init(force2: first)
    }

    public static func buildPartialBlock<F1, F2>(
        accumulated: F1,
        next: F2
    ) -> CompositedForce<Vector, F1, F2>
    where
        F1: ForceProtocol<Vector>, F2: ForceProtocol<Vector>,
        Vector: SimulatableVector & L2NormCalculatable,
        F1.Vector == Vector, F2.Vector == Vector
    {
        return CompositedForce<Vector, F1, F2>(force1: accumulated, force2: next)
    }

    public static func buildBlock<F1, F2>(
        _ force1: F1? = nil,
        _ force2: F2
    ) -> CompositedForce<Vector, F1, F2>
    where
        F1: ForceProtocol<Vector>, F2: ForceProtocol<Vector>,
        Vector: SimulatableVector & L2NormCalculatable,
        F1.Vector == Vector, F2.Vector == Vector
    {
        return CompositedForce(force1: force1, force2: force2)
    }

}


func a() {
    let comp = CompositedForce {
        Kinetics<SIMD2<Double>>.CenterForce(center: 0, strength: 0)
        Kinetics<SIMD2<Double>>.CollideForce(radius: .constant(0))
    }
}