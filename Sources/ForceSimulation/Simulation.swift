class Simulation<Vector, ForceField>
where Vector: SimulatableVector & L2NormCalculatable, ForceField: ForceProtocol<Vector> {

    @usableFromInline
    let forceField: ForceField

    @usableFromInline
    let kinetics: Kinetics<Vector>

    @inlinable
    public
    init(
        nodeCount: Int,
        forceField: ForceField,
        initialAlpha: Vector.Scalar = 1,
        alphaMin: Vector.Scalar = 1e-3,
        alphaDecay: Vector.Scalar = 2e-3,
        alphaTarget: Vector.Scalar = 0.0,
        velocityDecay: Vector.Scalar = 0.6
    ) {
        self.kinetics = Kinetics.createZeros(
            initialAlpha: initialAlpha,
            alphaMin: alphaMin,
            alphaDecay: alphaDecay,
            alphaTarget: alphaTarget,
            velocityDecay: velocityDecay,
            count: nodeCount
        )
        self.forceField = forceField
        self.forceField.bindKinetics(self.kinetics)
    }

    @inlinable
    func tick(iterations: UInt = 1) {
        for _ in 0..<iterations {
            self.kinetics.updateAlpha()
            self.forceField.apply()
            self.kinetics.updatePositions()
        }
    }

}


// struct Test {
//     // var simulation = Simulation<
//     //     SIMD2<Double>,
//     //     CompositedForce<SIMD2<Double>, CenterForce<SIMD2<Double>>, CenterForce<SIMD2<Double>>>
//     // >(nodeCount: 10, forceField: CompositedForce(force1: CenterForce(), force2: CenterForce()))

//     var mySimulation = Simulation(nodeCount: 10, forceField: MyForceField())

// }
