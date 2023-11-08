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

    public final class ManyBodyForce: ForceProtocol {

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
        @usableFromInline var precalculatedMass: [Vector.Scalar] = []

        @usableFromInline var forces: [Vector] = []

        @inlinable
        internal init(
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

            calculateForce(alpha: alpha)  //else { return }

            for i in 0..<self.kinetics.validCount {
                kinetics.position[i] += self.forces[i] / self.precalculatedMass[i]
            }
        }

        @inlinable
        internal func calculateForce(alpha: Vector.Scalar) {
            let coveringBox = KDBox<Vector>.cover(of: kinetics.position)

            let tree = KDTree(
                box: coveringBox
            ) {
                return switch self.mass {
                case .constant(let m):
                    MassCentroidKDTreeDelegate<Vector> { _ in m }
                case .varied(_):
                    MassCentroidKDTreeDelegate<Vector> { index in
                        self.precalculatedMass[index]
                    }
                }
            }

            for i in kinetics.position.indices {
                tree.add(i, at: kinetics.position[i])

                #if DEBUG
                    assert(tree.delegate.accumulatedCount == (i + 1))
                #endif

            }

            //        var forces = [simd_double2](repeating: .zero, count: sim.nodePositions.count)

            for i in kinetics.position.indices {
                var f = Vector.zero
                tree.visit { t in

                    guard t.delegate.accumulatedCount > 0 else { return false }
                    let centroid =
                        t.delegate.accumulatedMassWeightedPositions / t.delegate.accumulatedMass

                    let vec = centroid - kinetics.position[i]
                    let boxWidth = (t.box.p1 - t.box.p0)[0]
                    var distanceSquared = (vec.jiggled()).lengthSquared()

                    let farEnough: Bool =
                        (distanceSquared * self.theta2) > (boxWidth * boxWidth)

                    //                let distance = distanceSquared.squareRoot()

                    if distanceSquared < self.distanceMin2 {
                        distanceSquared = (self.distanceMin2 * distanceSquared).squareRoot()
                    }

                    if farEnough {

                        guard distanceSquared < self.distanceMax2 else { return true }

                        /// Workaround for "The compiler is unable to type-check this expression in reasonable time; try breaking up the expression into distinct sub-expressions"
                        let k: Vector.Scalar =
                            self.strength * alpha * t.delegate.accumulatedMass
                            / distanceSquared  // distanceSquared.squareRoot()

                        f += vec * k
                        return false

                    } else if t.children != nil {
                        return true
                    }

                    if t.isFilledLeaf {

                        //                    for j in t.nodeIndices {
                        //                        if j != i {
                        //                            let k: Double =
                        //                            self.strength * alpha * self.precalculatedMass[j] / distanceSquared / distanceSquared.squareRoot()
                        //                            f += vec * k
                        //                        }
                        //                    }
                        if t.nodeIndices.contains(i) { return false }

                        let massAcc = t.delegate.accumulatedMass
                        //                    t.nodeIndices.contains(i) ?  (t.delegate.accumulatedMass-self.precalculatedMass[i]) : (t.delegate.accumulatedMass)
                        let k: Vector.Scalar = self.strength * alpha * massAcc / distanceSquared  // distanceSquared.squareRoot()
                        f += vec * k
                        return false
                    } else {
                        return true
                    }
                }
                forces[i] = f
            }
        }

        @usableFromInline var kinetics: Kinetics! = nil

        @inlinable
        public func bindKinetics(_ kinetics: Kinetics) {
            self.kinetics = kinetics
            self.precalculatedMass = self.mass.calculate(for: (kinetics.validCount))
            self.forces = .init(repeating: .zero, count: kinetics.validCount)

        }
    }
}
