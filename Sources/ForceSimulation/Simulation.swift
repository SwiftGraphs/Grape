class Simulation<Vector, ForceField>
where Vector: SIMD, Vector.Scalar: FloatingPoint, ForceField: ForceProtocol<Vector> {
    let forceField: ForceField
    let kinetics: Kinetics<Vector>

    init(
        nodeCount: Int,
        forceField: ForceField
    ) {
        self.kinetics = Kinetics.createZeros(count: nodeCount)
        self.forceField = forceField
    }

}

struct MyForceField: ForceField {

    typealias Vector = SIMD2<Double>

    var force: some ForceProtocol<Vector> {
        CompositedForce(force1: CenterForce(), force2: CenterForce())
    }
}

struct Test {
    var simulation = Simulation<
        SIMD2<Double>,
        CompositedForce<SIMD2<Double>, CenterForce<SIMD2<Double>>, CenterForce<SIMD2<Double>>>
    >(nodeCount: 10, forceField: CompositedForce(force1: CenterForce(), force2: CenterForce()))

    var mySimulation = Simulation(nodeCount: 10, forceField: MyForceField())

}
