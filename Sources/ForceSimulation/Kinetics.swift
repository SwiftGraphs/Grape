/// A class that holds the state of the simulation, which
/// includes the positions, velocities of the nodes.
public struct Kinetics<Vector>: Disposable
where Vector: SimulatableVector & L2NormCalculatable {

    /// The position of points stored in simulation.
    ///
    /// Ordered as the nodeIds you passed in when initializing simulation.
    /// They are always updated.
    public var position: UnsafeArray<Vector>

    // public var positionBufferPointer: UnsafeMutablePointer<Vector>

    /// The velocities of points stored in simulation.
    ///
    /// Ordered as the nodeIds you passed in when initializing simulation.
    /// They are always updated.
    public var velocity: UnsafeArray<Vector>

    // public var velocityBufferPointer: UnsafeMutablePointer<Vector>

    /// The fixed positions of points stored in simulation.
    ///
    /// Ordered as the nodeIds you passed in when initializing simulation.
    /// They are always updated.
    public var fixation: UnsafeArray<Vector?>


    public var validCount: Int
    public var alpha: Vector.Scalar
    public let alphaMin: Vector.Scalar
    public let alphaDecay: Vector.Scalar
    public let alphaTarget: Vector.Scalar

    public let velocityDecay: Vector.Scalar

    @usableFromInline
    var randomGenerator: Vector.Scalar.Generator


    public let links: [EdgeID<Int>]

    // public var validRanges: [Range<Int>]
    // public var validRanges: Range<Int>

    @inlinable
    public var range: Range<Int> {
        return 0..<validCount
    }

    @inlinable
    init(
        links: [EdgeID<Int>],
        initialAlpha: Vector.Scalar,
        alphaMin: Vector.Scalar,
        alphaDecay: Vector.Scalar,
        alphaTarget: Vector.Scalar,
        velocityDecay: Vector.Scalar,
        position: [Vector],
        velocity: consuming [Vector],
        fixation: consuming [Vector?]
    ) {
        self.links = links
        // self.initializedAlpha = initialAlpha
        self.alpha = initialAlpha
        self.alphaMin = alphaMin
        self.alphaDecay = alphaDecay
        self.alphaTarget = alphaTarget
        self.velocityDecay = velocityDecay

        let count = position.count
        self.validCount = count

        self.position = .createBuffer(moving: consume position, fillingWithIfFailed: .zero)
        self.velocity = .createBuffer(moving: velocity, fillingWithIfFailed: .zero)
        self.fixation = .createBuffer(moving: fixation, fillingWithIfFailed: nil)
        self.randomGenerator = .init()
    }

    // @inlinable
    // init(
    //     links: [EdgeID<Int>],
    //     initialAlpha: Vector.Scalar,
    //     alphaMin: Vector.Scalar,
    //     alphaDecay: Vector.Scalar,
    //     alphaTarget: Vector.Scalar,
    //     velocityDecay: Vector.Scalar,
    //     position: consuming [Vector],
    //     velocity: consuming [Vector],
    //     fixation: consuming [Vector?],
    //     randomSeed: Vector.Scalar.Generator.OverflowingInteger
    // ) {
    //     self.links = links
    //     self.initializedAlpha = initialAlpha
    //     self.alpha = initialAlpha
    //     self.alphaMin = alphaMin
    //     self.alphaDecay = alphaDecay
    //     self.alphaTarget = alphaTarget
    //     self.velocityDecay = velocityDecay
    //     let count = position.count
    //     self.validCount = count

    //     self.position = UnsafeArray<Vector>.createBuffer(
    //         withHeader: count,
    //         count: count,
    //         initialValue: .zero
    //     )

    //     self.velocity = UnsafeArray<Vector>.createBuffer(
    //         withHeader: count,
    //         count: count,
    //         initialValue: .zero
    //     )
    //     self.fixation = UnsafeArray<Vector?>.createBuffer(
    //         withHeader: count,
    //         count: count,
    //         initialValue: nil
    //     )

    //     self.randomGenerator = .allocate(capacity: 1)
    //     self.randomGenerator.initialize(to: .init(seed: randomSeed))
    // }

    // @inlinable
    // internal func jigglePosition() {
    //     for i in range {
    //         position[i] = position[i].jiggled(by: self.randomGenerator)
    //     }
    // }

    // @inlinable
    // static func createZeros(
    //     links: [EdgeID<Int>],
    //     initialAlpha: Vector.Scalar,
    //     alphaMin: Vector.Scalar,
    //     alphaDecay: Vector.Scalar,
    //     alphaTarget: Vector.Scalar,
    //     velocityDecay: Vector.Scalar,
    //     count: Int
    // ) -> Kinetics<Vector> {
    //     return Kinetics(
    //         links: links,
    //         initialAlpha: initialAlpha,
    //         alphaMin: alphaMin,
    //         alphaDecay: alphaDecay,
    //         alphaTarget: alphaTarget,
    //         velocityDecay: velocityDecay,

    //         position: Array(repeating: .zero, count: count),
    //         velocity: Array(repeating: .zero, count: count),
    //         fixation: Array(repeating: nil, count: count)
    //     )
    // }

    @inlinable
    public func dispose() {
        // self.randomGenerator.deinitialize(count: 1)
        // self.randomGenerator.deallocate()
    }
}

extension Kinetics {
    @inlinable
    @inline(__always)
    func updatePositions() {
        for i in range {
            if let fix = fixation[i] {
                position[i] = fix
            } else {
                velocity[i] *= velocityDecay
                position[i] += velocity[i]
            }
        }
    }

    @inlinable
    @inline(__always)
    mutating func updateAlpha() {
        alpha += alphaTarget - alpha * alphaDecay
    }

}

public typealias Kinetics2D = Kinetics<SIMD2<Double>>
public typealias Kinetics3D = Kinetics<SIMD3<Float>>
