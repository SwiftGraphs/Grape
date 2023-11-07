public protocol SimulatableAttribute<Vector, Value> {
    associatedtype Vector where Vector: SIMD, Vector.Scalar: FloatingPoint
    associatedtype Value
}

extension SIMD2: SimulatableAttribute where Scalar: FloatingPoint {
    public typealias Vector = Self
    public typealias Value = Self
}

extension SIMD3: SimulatableAttribute where Scalar: FloatingPoint {
    public typealias Vector = Self
    public typealias Value = Self
}

final class Kinetics<Vector> where Vector: SIMD, Vector.Scalar: FloatingPoint {
    var position: [Vector]
    var velocity: [Vector]
    var fixation: [Vector]

    init(position: [Vector], velocity: [Vector], fixation: [Vector]) {
        self.position = position
        self.velocity = velocity
        self.fixation = fixation
    }

    class func createZeros(count: Int) -> Kinetics<Vector> {
        return Kinetics(
            position: Array(repeating: .zero, count: count), 
            velocity: Array(repeating: .zero, count: count), 
            fixation: Array(repeating: .zero, count: count)
        )
    }
}
