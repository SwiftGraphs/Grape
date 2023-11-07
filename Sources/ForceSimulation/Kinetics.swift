public final class Kinetics<Vector>
where Vector: SimulatableVector & L2NormCalculatable {
    public var position: [Vector]
    public var velocity: [Vector]
    public var fixation: [Vector?]

    public let initializedAlpha: Vector.Scalar

    public var alpha: Vector.Scalar
    public var alphaMin: Vector.Scalar
    public var alphaDecay: Vector.Scalar
    public var alphaTarget: Vector.Scalar

    public let velocityDecay: Vector.Scalar

    // public var validRanges: [Range<Int>]
    // public var validRanges: Range<Int>
    public var validCount: Int
    @inlinable 
    public var range: Range<Int> {
        return 0..<validCount
    }
    // {
    //     return validRanges.reduce(0) { $0 + $1.count }
    // }

    @inlinable
    init(
        initialAlpha: Vector.Scalar,
        alphaMin: Vector.Scalar,
        alphaDecay: Vector.Scalar,
        alphaTarget: Vector.Scalar,
        velocityDecay: Vector.Scalar,
        position: [Vector],
        velocity: [Vector],
        fixation: [Vector?]
    ) {
        self.initializedAlpha = initialAlpha
        self.alpha = initialAlpha
        self.alphaMin = alphaMin
        self.alphaDecay = alphaDecay
        self.alphaTarget = alphaTarget
        self.velocityDecay = velocityDecay

        // self.validRanges = 0..<position.count
        self.validCount = position.count

        self.position = position
        self.velocity = velocity
        self.fixation = fixation
    }

    @inlinable
    class func createZeros(
        initialAlpha: Vector.Scalar,
        alphaMin: Vector.Scalar,
        alphaDecay: Vector.Scalar,
        alphaTarget: Vector.Scalar,
        velocityDecay: Vector.Scalar,
        count: Int
    ) -> Kinetics<Vector> {
        return Kinetics(
            initialAlpha: initialAlpha,
            alphaMin: alphaMin,
            alphaDecay: alphaDecay,
            alphaTarget: alphaTarget,
            velocityDecay: velocityDecay,

            position: Array(repeating: .zero, count: count),
            velocity: Array(repeating: .zero, count: count),
            fixation: Array(repeating: nil, count: count)
        )
    }
}

extension Kinetics {
    @inlinable
    func updatePositions() {
        for i in position.indices {
            if let fix = fixation[i] {
                position[i] = fix
            } else {
                velocity[i] *= velocityDecay
                position[i] += velocity[i]
            }
        }
    }

    @inlinable
    func updateAlpha() {
        alpha += (alphaTarget - alpha) * alphaDecay
    }

    @inlinable
    func invalidateRange(_ range: Range<Int>) {
        fatalError("Not implemented")
    }

    @inlinable
    func validateRangeAndExtendIfNeccessary(_ range: Range<Int>) {
        fatalError("Not implemented")
    }

}

// struct UnsafeKinetics {
//     var position: ManagedBufferPointer<Int, SIMD2<Double>>
// }
