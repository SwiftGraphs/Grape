/// Workaround for yet unsupported packed generic pack types & same type requirements
public struct CompositedForce<Vector, F1, F2>: ForceProtocol
where
    F1: ForceProtocol<Vector>, F2: ForceProtocol<Vector>,
    Vector: SimulatableVector & L2NormCalculatable,
    F1.Vector == Vector, F2.Vector == Vector, F1.Vector == Vector
{

    @usableFromInline var force1: F1?
    @usableFromInline var force2: F2

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
    public func dispose() {
        self.force1?.dispose()
        self.force2.dispose()
    }
    
    
    @inlinable
    public mutating func bindKinetics(_ kinetics: Kinetics<Vector>) {
        self.force1?.bindKinetics(kinetics)
        self.force2.bindKinetics(kinetics)
    }

    @inlinable
    public init(@ForceBuilder<Vector> _ builder: () -> CompositedForce<Vector, F1, F2>) {
        self = builder()
    }
}

// public typealias CompositedForce2D<F1, F2> = CompositedForce<SIMD2<Double>, F1, F2>
// where F1: ForceProtocol<SIMD2<Double>>, F2: ForceProtocol<SIMD2<Double>>

// public typealias CompositedForce3D<F1, F2> = CompositedForce<SIMD3<Double>, F1, F2>
// where F1: ForceProtocol<SIMD3<Double>>, F2: ForceProtocol<SIMD3<Double>>


@resultBuilder
public struct ForceBuilder<Vector>
where Vector: SimulatableVector & L2NormCalculatable {

    public static func buildPartialBlock<F>(first: F) -> F// CompositedForce<Vector, Kinetics<Vector>.EmptyForce, F>
    where F: ForceProtocol<Vector>, Vector: SimulatableVector & L2NormCalculatable {
        return first //.init(force2: first)
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


    public static func buildExpression<Descriptor: ForceDescriptor>(
        _ expression: Descriptor
    ) -> Descriptor.ConcreteForce {
        expression.createForce()
    }

        public static func buildExpression<F: ForceProtocol>(
        _ expression: F
    ) -> F {
        expression
    }
}
