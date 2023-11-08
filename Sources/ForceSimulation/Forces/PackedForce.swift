// struct PackedForce<Vector, each Force>: ForceProtocol where Vector: SIMD, Vector.Scalar: FloatingPoint, repeat each Force: ForceProtocol<Vector> {
//     let forces: (repeat each Force)

//     // var kinetics: Kinetics<Vector>?

//     init(forces: repeat each Force) {
//         self.forces = (repeat each forces)
//     }

//     func apply() {
//         repeat (each forces).apply()
//     }

//     func bindKinetics(_ kinetics: Kinetics<Vector>) {
//         repeat (each forces).bindKinetics(kinetics)
//     }
// }