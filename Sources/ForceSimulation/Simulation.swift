/// An any-dimensional force simulation.
/// The points are placed in a space where you use a SIMD data structure
/// to describe their coordinates.
public final class Simulation<Vector, ForceField>
where Vector: SimulatableVector & L2NormCalculatable, ForceField: ForceProtocol<Vector> {

    @usableFromInline
    var forceField: ForceField

    public var kinetics: Kinetics<Vector>

    /// Create a new simulation.
    ///
    /// - Parameters:
    ///   - nodeCount: Count of the nodes. Force simulation calculate them by order once created.
    ///   - links: The links between nodes.
    ///   - forceField: The force field that drives the simulation. The simulation takes ownership of the force field.
    ///   - alpha: Initial alpha value, determines how "active" the simulation is.
    ///   - alphaMin: The minimum alpha value. The simulation stops when alpha is less than this value.
    ///   - alphaDecay: The larger the value, the faster the simulation converges to the final result.
    ///   - alphaTarget: The alpha value the simulation converges to.
    ///   - velocityDecay: A multiplier for the velocity of the nodes in Velocity Verlet integration. The position of the nodes is updated by the formula `x += v * velocityDecay`.
    // @inlinable
    // public init(
    //     nodeCount: Int,
    //     links: [EdgeID<Int>],
    //     forceField: ForceField,
    //     initialAlpha: Vector.Scalar = 1,
    //     alphaMin: Vector.Scalar = 1e-2,
    //     alphaDecay: Vector.Scalar = 2e-3,
    //     alphaTarget: Vector.Scalar = 0.0,
    //     velocityDecay: Vector.Scalar = 0.6
    // ) {
    //     self.kinetics = .createZeros(
    //         links: links,
    //         initialAlpha: initialAlpha,
    //         alphaMin: alphaMin,
    //         alphaDecay: alphaDecay,
    //         alphaTarget: alphaTarget,
    //         velocityDecay: velocityDecay,
    //         count: nodeCount
    //     )
    //     // self.kinetics.jigglePosition()
    //     forceField.bindKinetics(self.kinetics)
    //     self.forceField = forceField
    // }

    /// Create a new simulation.
    ///
    /// - Parameters:
    ///   - nodeCount: Count of the nodes. Force simulation calculate them by order once created.
    ///   - links: The links between nodes.
    ///   - forceField: The force field that drives the simulation. The simulation takes ownership of the force field.
    ///   - alpha: Initial alpha value, determines how "active" the simulation is.
    ///   - alphaMin: The minimum alpha value. The simulation stops when alpha is less than this value.
    ///   - alphaDecay: The larger the value, the faster the simulation converges to the final result.
    ///   - alphaTarget: The alpha value the simulation converges to.
    ///   - velocityDecay: A multiplier for the velocity of the nodes in Velocity Verlet integration. The position of the nodes is updated by the formula `x += v * velocityDecay`.
    @inlinable
    public init(
        nodeCount: Int,
        links: [EdgeID<Int>],
        forceField: consuming ForceField,
        initialAlpha: Vector.Scalar = 1,
        alphaMin: Vector.Scalar = 1e-3,
        alphaDecay: Vector.Scalar = 2e-3,
        alphaTarget: Vector.Scalar = 0.0,
        velocityDecay: Vector.Scalar = 0.6,
        position: [Vector]? = nil,
        velocity: [Vector]? = nil,
        fixation: [Vector?]? = nil
    ) {

        self.kinetics = Kinetics(
            links: links,
            initialAlpha: initialAlpha,
            alphaMin: alphaMin,
            alphaDecay: alphaDecay,
            alphaTarget: alphaTarget,
            velocityDecay: velocityDecay,
            position: position ?? Array(repeating: .zero, count: nodeCount),
            velocity: velocity ?? Array(repeating: .zero, count: nodeCount),
            fixation: fixation ?? Array(repeating: nil, count: nodeCount)
        )
        // self.kinetics.jigglePosition()
        forceField.bindKinetics(self.kinetics)
        self.forceField = forceField
    }

    /// Run a number of iterations of ticks.
    @inlinable
    public func tick(iterations: UInt = 1) {
        // print(self.kinetics.alpha, self.kinetics.alphaMin)
        guard self.kinetics.alpha >= self.kinetics.alphaMin else { return }
        for _ in 0..<iterations {
            self.kinetics.updateAlpha()
            self.forceField.apply(to: &self.kinetics)
            self.kinetics.updatePositions()
        }
    }

    deinit {
        self.forceField.dispose()
    }

}


public typealias Simulation2D<ForceField> = Simulation<SIMD2<Double>, ForceField>
where ForceField: ForceProtocol<SIMD2<Double>>

public typealias Simulation3D<ForceField> = Simulation<SIMD3<Float>, ForceField>
where ForceField: ForceProtocol<SIMD3<Float>>
