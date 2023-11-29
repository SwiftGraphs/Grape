/// A class that holds the state of the simulation, which
/// includes the positions, velocities of the nodes.
public final class Kinetics<Vector>
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

    // public var fixationBufferPointer: UnsafeMutablePointer<Vector?>

    public var links: [EdgeID<Int>]

    public let initializedAlpha: Vector.Scalar

    public var alpha: Vector.Scalar
    public var alphaMin: Vector.Scalar
    public var alphaDecay: Vector.Scalar
    public var alphaTarget: Vector.Scalar

    public let velocityDecay: Vector.Scalar

    @usableFromInline
    let randomGenerator: UnsafeMutablePointer<Vector.Scalar.Generator>

    // public var validRanges: [Range<Int>]
    // public var validRanges: Range<Int>
    public var validCount: Int

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
        velocity: [Vector],
        fixation: [Vector?]
    ) {
        self.links = links
        self.initializedAlpha = initialAlpha
        self.alpha = initialAlpha
        self.alphaMin = alphaMin
        self.alphaDecay = alphaDecay
        self.alphaTarget = alphaTarget
        self.velocityDecay = velocityDecay

        // self.validRanges = 0..<position.count
        self.validCount = position.count

        self.position = UnsafeArray<Vector>.createBuffer(
            withHeader: position.count,
            count: position.count,
            initialValue: .zero
        )
        self.velocity = UnsafeArray<Vector>.createBuffer(
            withHeader: position.count,
            count: position.count,
            initialValue: .zero
        )
        self.fixation = UnsafeArray<Vector?>.createBuffer(
            withHeader: position.count,
            count: position.count,
            initialValue: nil
        )

        self.randomGenerator = .allocate(capacity: 1)
        self.randomGenerator.initialize(to: .init())
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
        velocity: [Vector],
        fixation: [Vector?],
        randomSeed: Vector.Scalar
    ) {
        self.links = links
        self.initializedAlpha = initialAlpha
        self.alpha = initialAlpha
        self.alphaMin = alphaMin
        self.alphaDecay = alphaDecay
        self.alphaTarget = alphaTarget
        self.velocityDecay = velocityDecay
        self.validCount = position.count

        self.position = UnsafeArray<Vector>.createBuffer(
            withHeader: position.count,
            count: position.count,
            initialValue: .zero
        )
        self.velocity = UnsafeArray<Vector>.createBuffer(
            withHeader: position.count,
            count: position.count,
            initialValue: .zero
        )
        self.fixation = UnsafeArray<Vector?>.createBuffer(
            withHeader: position.count,
            count: position.count,
            initialValue: nil
        )

        self.randomGenerator = .allocate(capacity: 1)
        self.randomGenerator.initialize(to: .init(seed: randomSeed))
    }

    @inlinable
    static func createZeros(
        links: [EdgeID<Int>],
        initialAlpha: Vector.Scalar,
        alphaMin: Vector.Scalar,
        alphaDecay: Vector.Scalar,
        alphaTarget: Vector.Scalar,
        velocityDecay: Vector.Scalar,
        count: Int
    ) -> Kinetics<Vector> {
        return Kinetics(
            links: links,
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

    deinit {
        self.randomGenerator.deinitialize(count: 1)
        self.randomGenerator.deallocate()
    }
}

extension Kinetics {
    @inlinable
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

public typealias Kinetics2D = Kinetics<SIMD2<Double>>
public typealias Kinetics3D = Kinetics<SIMD3<Float>>
