@usableFromInline
internal struct MaxRadiusKDTreeDelegate<Vector>: KDTreeDelegate
where Vector: SimulatableVector {
    @inlinable
    mutating func didAddNode(_ node: Int, at position: Vector) {
        let p = radiusGetter(node)
        maxNodeRadius = max(maxNodeRadius, p)
    }

    @usableFromInline
    var radiusGetter: (Int) -> Vector.Scalar

    public var maxNodeRadius: Vector.Scalar = .zero

    @inlinable
    mutating func didRemoveNode(_ node: Int, at position: Vector) {
        if radiusGetter(node) >= maxNodeRadius {
            // 🤯 for Collide force, set to 0 is fine
            // Otherwise you need to traverse the delegate again
            maxNodeRadius = 0
        }
    }

    @inlinable
    func copy() -> MaxRadiusKDTreeDelegate<Vector> {
        return self
    }

    @inlinable
    func spawn() -> MaxRadiusKDTreeDelegate<Vector> {
        return Self(radiusProvider: radiusGetter)
    }

    @usableFromInline typealias NodeID = Int

    @inlinable
    init(maxNodeRadius: Vector.Scalar = 0, radiusProvider: @escaping (NodeID) -> Vector.Scalar) {
        self.maxNodeRadius = maxNodeRadius
        self.radiusGetter = radiusProvider
    }
}

extension Kinetics {



    public typealias CollideRadius = AttributeDescriptor<Vector.Scalar>

    public final class CollideForce: ForceProtocol {

        @usableFromInline var kinetics: Kinetics! = nil

        public var radius: CollideRadius

        public let iterationsPerTick: UInt
        public var strength: Vector.Scalar

        @inlinable
        init(
            radius: CollideRadius,
            strength: Vector.Scalar = 1.0,
            iterationsPerTick: UInt = 1
        ) {
            self.radius = radius
            self.iterationsPerTick = iterationsPerTick
            self.strength = strength
        }

        @inlinable
        public func bindKinetics(_ kinetics: Kinetics) {
            self.kinetics = kinetics
            self.calculatedRadius = self.radius.calculate(for: kinetics.validCount)
        }

        @usableFromInline
        var calculatedRadius: [Vector.Scalar] = []

        public func apply() {
            assert(self.kinetics != nil, "Kinetics not bound to force")

            // let alpha = kinetics.alpha

            for _ in 0..<iterationsPerTick {

                let coveringBox = KDBox<Vector>.cover(of: kinetics.position)

                let tree = KDTree<Vector, MaxRadiusKDTreeDelegate<Vector>>(
                    box: coveringBox
                ) {
                    return switch self.radius {
                    case .constant(let m):
                        MaxRadiusKDTreeDelegate<Vector> { _ in m }
                    case .varied(_):
                        MaxRadiusKDTreeDelegate<Vector> { index in
                            self.calculatedRadius[index]
                        }
                    }
                }

                for i in kinetics.range {
                    tree.add(i, at: kinetics.position[i])
                }

                for i in kinetics.range {
                    let iOriginalPosition = kinetics.position[i]
                    let iOriginalVelocity = kinetics.velocity[i]
                    let iR = self.calculatedRadius[i]
                    let iR2 = iR * iR
                    let iPosition = iOriginalPosition + iOriginalVelocity

                    tree.visit { t in

                        let maxRadiusOfQuad = t.delegate.maxNodeRadius
                        let deltaR = maxRadiusOfQuad + iR

                        if t.nodePosition != nil {
                            for j in t.nodeIndices {
                                //                            print("\(i)<=>\(j)")
                                // is leaf, make sure every collision happens once.
                                guard j > i else { continue }

                                let jR = self.calculatedRadius[j]
                                let jOriginalPosition = kinetics.position[j]
                                let jOriginalVelocity = kinetics.velocity[j]
                                var deltaPosition =
                                    iPosition - (jOriginalPosition + jOriginalVelocity)
                                let l = (deltaPosition).lengthSquared()

                                let deltaR = iR + jR
                                if l < deltaR * deltaR {

                                    var l = /*simd_length*/ (deltaPosition.jiggled()).length()
                                    l = (deltaR - l) / l * self.strength

                                    let jR2 = jR * jR

                                    let k = jR2 / (iR2 + jR2)

                                    deltaPosition *= l

                                    kinetics.velocity[i] += deltaPosition * k
                                    kinetics.velocity[j] -= deltaPosition * (1 - k)
                                }
                            }
                            return false
                        }

                        // TODO: SIMD mask

                        for laneIndex in t.box.p0.indices {
                            let _v = t.box.p0[laneIndex]
                            if _v > iPosition[laneIndex] + deltaR /* True if no overlap */ {
                                return false
                            }
                        }

                        for laneIndex in t.box.p1.indices {
                            let _v = t.box.p1[laneIndex]
                            if _v < iPosition[laneIndex] - deltaR /* True if no overlap */ {
                                return false
                            }
                        }
                        return true
                    }
                }
            }
        }

    }
}
