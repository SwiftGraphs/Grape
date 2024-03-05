public struct MaxRadiusNDTreeDelegate<Vector>: KDTreeDelegate
where Vector: SimulatableVector {

    @usableFromInline
    var radiusBufferPointer: UnsafeMutablePointer<Vector.Scalar>

    public var maxNodeRadius: Vector.Scalar = .zero

    @inlinable
    public mutating func didAddNode(_ node: Int, at position: Vector) {
        maxNodeRadius = max(maxNodeRadius, radiusBufferPointer[node])
    }

    @inlinable
    public mutating func didRemoveNode(_ node: Int, at position: Vector) {
        if radiusBufferPointer[node] >= maxNodeRadius {
            // 🤯 for Collide force, set to 0 is fine
            // Otherwise you need to traverse the delegate again
            maxNodeRadius = 0
        }
    }

    @inlinable
    public func spawn() -> MaxRadiusNDTreeDelegate<Vector> {
        return Self(radiusBufferPointer: radiusBufferPointer)
    }

    @inlinable
    init(maxNodeRadius: Vector.Scalar = 0, radiusBufferPointer: UnsafeMutablePointer<Vector.Scalar>)
    {
        self.maxNodeRadius = maxNodeRadius
        self.radiusBufferPointer = radiusBufferPointer
    }
}

extension Kinetics {

    public typealias CollideRadius = AttributeDescriptor<Vector.Scalar>

    /// A force that prevents nodes from overlapping.
    ///
    /// This is a very expensive force, the complexity is `O(n log(n))`,
    /// where `n` is the number of nodes.
    /// See [Collide Force - D3](https://d3js.org/d3-force/collide).
    public struct CollideForce: ForceProtocol {

        // @usableFromInline
        // var kinetics: Kinetics! = nil

        public var radius: CollideRadius

        public let iterationsPerTick: UInt
        public var strength: Vector.Scalar

        @inlinable
        public init(
            radius: CollideRadius,
            strength: Vector.Scalar = 1.0,
            iterationsPerTick: UInt = 1
        ) {
            self.radius = radius
            self.iterationsPerTick = iterationsPerTick
            self.strength = strength
        }

        @inlinable
        public mutating func bindKinetics(_ kinetics: Kinetics) {
            // self.kinetics = kinetics
            self.calculatedRadius = self.radius.calculateUnsafe(for: kinetics.validCount)
            self.tree = .allocate(capacity: 1)
            self.tree.initialize(
                to:
                    BufferedKDTree(
                        rootBox: .init(
                            p0: .init(repeating: 0),
                            p1: .init(repeating: 1)
                        ),
                        nodeCapacity: kinetics.validCount,
                        rootDelegate: .init(
                            radiusBufferPointer: self.calculatedRadius.mutablePointer)
                    )
            )
        }

        @usableFromInline
        var calculatedRadius: UnsafeArray<Vector.Scalar>! = nil

        @usableFromInline
        internal var tree:
            UnsafeMutablePointer<BufferedKDTree<Vector, MaxRadiusNDTreeDelegate<Vector>>>! = nil

        @inlinable
        public func apply(to kinetics: inout Kinetics<Vector>) {
            

            let strength = self.strength
            let calculatedRadius = self.calculatedRadius!.mutablePointer
            let positionBufferPointer = kinetics.position.mutablePointer
            let velocityBufferPointer = kinetics.velocity.mutablePointer

            let tree = self.tree!

            for _ in 0..<iterationsPerTick {

                let coveringBox = KDBox<Vector>.cover(of: kinetics.position)

                tree.pointee.reset(
                    rootBox: coveringBox,
                    rootDelegate: .init(radiusBufferPointer: calculatedRadius)
                )
                assert(tree.pointee.validCount == 1)

                for p in kinetics.range {
                    tree.pointee.add(nodeIndex: p, at: positionBufferPointer[p])
                }

                for i in kinetics.range {
                    let iOriginalPosition = positionBufferPointer[i]
                    let iOriginalVelocity = velocityBufferPointer[i]
                    let iR = calculatedRadius[i]
                    let iR2 = iR * iR
                    let iPosition = iOriginalPosition + iOriginalVelocity

                    tree.pointee.visit { t in

                        let maxRadiusOfQuad = t.delegate.maxNodeRadius
                        let deltaR = maxRadiusOfQuad + iR

                        if var jNode = t.nodeIndices {
                            while true {
                                let j = jNode.index
                                //                            print("\(i)<=>\(j)")
                                // is leaf, make sure every collision happens once.
                                if j > i {

                                    let jR = calculatedRadius[j]
                                    let jOriginalPosition = positionBufferPointer[j]
                                    let jOriginalVelocity = velocityBufferPointer[j]
                                    var deltaPosition =
                                        iPosition - (jOriginalPosition + jOriginalVelocity)
                                    let l = (deltaPosition).lengthSquared()

                                    let deltaR = iR + jR
                                    if l < deltaR * deltaR {

                                        var l = /*simd_length*/ (deltaPosition.jiggled(by: &kinetics.randomGenerator))
                                            .length()
                                        l = (deltaR - l) / l * strength

                                        let jR2 = jR * jR

                                        let k = jR2 / (iR2 + jR2)

                                        deltaPosition *= l

                                        velocityBufferPointer[i] += deltaPosition * k
                                        velocityBufferPointer[j] -= deltaPosition * (1 - k)
                                    }
                                }
                                if jNode.next == nil {
                                    break
                                } else {
                                    jNode = jNode.next!.pointee
                                }
                            }
                            return false
                        }

                        // TODO: SIMD mask

                        // for laneIndex in t.box.p0.indices {
                        //     let _v = t.box.p0[laneIndex]
                        //     if _v > iPosition[laneIndex] + deltaR /* True if no overlap */ {
                        //         return false
                        //     }
                        // }

                        // for laneIndex in t.box.p1.indices {
                        //     let _v = t.box.p1[laneIndex]
                        //     if _v < iPosition[laneIndex] - deltaR /* True if no overlap */ {
                        //         return false
                        //     }
                        // }

                        let p0Flag = t.box.p0 .> (iPosition + deltaR)
                        let p1Flag = t.box.p1 .< (iPosition - deltaR)
                        let flag = p0Flag .| p1Flag

                        for laneIndex in t.box.p0.indices {
                            if flag[laneIndex] {
                                return false
                            }
                            // let _v = t.box.p1[laneIndex]
                            // if (t.box.p0[laneIndex] > iPosition[laneIndex] + deltaR)
                            //     || (t.box.p1[laneIndex] < iPosition[laneIndex]
                            //         - deltaR) /* True if no overlap */
                            // {
                            //     return false
                            // }
                        }
                        return true
                    }
                }
            }
        }

        /// Deinitialize the tree and deallocate the memory.
        /// Called when `Simulation` is deinitialized.
        @inlinable
        public func dispose() {
            self.tree.dispose()
        }

    }
}
