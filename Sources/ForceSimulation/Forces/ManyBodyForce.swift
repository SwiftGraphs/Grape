@usableFromInline
internal struct MassCentroidKDTreeDelegate<Vector>: KDTreeDelegate
where Vector: SimulatableVector {

    public var accumulatedMass: Vector.Scalar = .zero
    public var accumulatedCount: Int = 0
    public var accumulatedMassWeightedPositions: Vector = .zero

    @usableFromInline let massProvider: (NodeID) -> Vector.Scalar

    @inlinable
    init(massProvider: @escaping (Int) -> Vector.Scalar) {
        self.massProvider = massProvider
    }

    @inlinable
    init(
        initialAccumulatedProperty: Vector.Scalar,
        initialAccumulatedCount: Int,
        initialWeightedAccumulatedNodePositions: Vector,
        massProvider: @escaping (Int) -> Vector.Scalar
    ) {
        self.accumulatedMass = initialAccumulatedProperty
        self.accumulatedCount = initialAccumulatedCount
        self.accumulatedMassWeightedPositions = initialWeightedAccumulatedNodePositions
        self.massProvider = massProvider
    }

    @inlinable public mutating func didAddNode(_ node: Int, at position: Vector) {
        let p = massProvider(node)
        #if DEBUG
            assert(p > 0)
        #endif
        accumulatedCount += 1
        accumulatedMass += p
        accumulatedMassWeightedPositions += position * p
    }

    @inlinable public mutating func didRemoveNode(_ node: Int, at position: Vector) {
        let p = massProvider(node)
        accumulatedCount -= 1
        accumulatedMass -= p
        accumulatedMassWeightedPositions -= position * p
        // TODO: parent removal?
    }

    @inlinable public func copy() -> Self {
        return Self(
            initialAccumulatedProperty: self.accumulatedMass,
            initialAccumulatedCount: self.accumulatedCount,
            initialWeightedAccumulatedNodePositions: self.accumulatedMassWeightedPositions,
            massProvider: self.massProvider
        )
    }

    @inlinable public func spawn() -> Self {
        return Self(massProvider: self.massProvider)
    }
}

extension Kinetics {
    public typealias NodeMass = AttributeDescriptor<Vector.Scalar>

    /// A force that simulate the many-body force.
    ///
    /// This is a very expensive force, the complexity is `O(n log(n))`,
    /// where `n` is the number of nodes. The complexity might degrade to `O(n^2)` if the nodes are too close to each other.
    /// See [Manybody Force - D3](https://d3js.org/d3-force/many-body).
    public struct ManyBodyForce: ForceProtocol {

        @usableFromInline var strength: Vector.Scalar
        @usableFromInline var theta2: Vector.Scalar
        @usableFromInline var theta: Vector.Scalar {
            didSet {
                theta2 = theta * theta
            }
        }
        @usableFromInline var distanceMin2: Vector.Scalar = 1
        @usableFromInline var distanceMax2: Vector.Scalar = .infinity
        @usableFromInline var distanceMin: Vector.Scalar = 1
        @usableFromInline var distanceMax: Vector.Scalar = .infinity

        public var mass: NodeMass
        @usableFromInline var precalculatedMass: UnsafeArray<Vector.Scalar>! = nil

        // @usableFromInline var forces: [Vector] = []

        @inlinable
        public init(
            strength: Vector.Scalar,
            nodeMass: NodeMass = .constant(1.0),
            theta: Vector.Scalar = 0.9
        ) {
            self.strength = strength
            self.mass = nodeMass
            self.theta = theta
            self.theta2 = theta * theta
        }

        @inlinable
        public func apply() {

            let alpha = self.kinetics.alpha

            let theta2 = self.theta2
            let distanceMin2 = self.distanceMin2
            let distanceMax2 = self.distanceMax2
            let strength = self.strength
            let precalculatedMass = self.precalculatedMass!
            let mass = self.mass
            let kinetics = self.kinetics!

            var tree = KDTree(
                covering: kinetics.position
            ) {
                return switch mass {
                case .constant(let m):
                    MassCentroidKDTreeDelegate<Vector> { _ in m }
                case .varied(_):
                    MassCentroidKDTreeDelegate<Vector> { index in
                        precalculatedMass[index]
                    }
                }
            }

            for i in kinetics.range {
                let pos = kinetics.position[i]
                var f = Vector.zero
                tree.visit { t in

                    guard t.delegate.accumulatedCount > 0 else { return false }
                    let centroid =
                        t.delegate.accumulatedMassWeightedPositions / t.delegate.accumulatedMass

                    let vec = centroid - pos
                    let boxWidth = (t.box.p1 - t.box.p0)[0]
                    var distanceSquared = (vec.jiggled()).lengthSquared()

                    let farEnough: Bool =
                        (distanceSquared * theta2) > (boxWidth * boxWidth)

                    if distanceSquared < distanceMin2 {
                        distanceSquared = (distanceMin2 * distanceSquared).squareRoot()
                    }

                    if farEnough {

                        guard distanceSquared < distanceMax2 else { return true }

                        /// Workaround for "The compiler is unable to type-check this expression in reasonable time; try breaking up the expression into distinct sub-expressions"
                        let k: Vector.Scalar =
                            strength * alpha * t.delegate.accumulatedMass
                            / distanceSquared  // distanceSquared.squareRoot()

                        f += vec * k
                        return false

                    } else if t.children != nil {
                        return true
                    }

                    if t.isFilledLeaf {

                        if t.nodeIndices.contains(i) { return false }

                        let massAcc = t.delegate.accumulatedMass
                        //                    t.nodeIndices.contains(i) ?  (t.delegate.accumulatedMass-self.precalculatedMass[i]) : (t.delegate.accumulatedMass)
                        let k: Vector.Scalar = strength * alpha * massAcc / distanceSquared  // distanceSquared.squareRoot()
                        f += vec * k
                        return false
                    } else {
                        return true
                    }
                }

                kinetics.position[i] += f / precalculatedMass[i]
            }
        }

        @usableFromInline var kinetics: Kinetics! = nil

        @inlinable
        public mutating func bindKinetics(_ kinetics: Kinetics) {
            self.kinetics = kinetics
            self.precalculatedMass = self.mass.calculateUnsafe(for: (kinetics.validCount))
            // self.forces = .init(repeating: .zero, count: kinetics.validCount)

        }
    }
}
