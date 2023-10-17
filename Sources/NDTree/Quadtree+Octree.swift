//
//  File 2.swift
//
//
//  Created by li3zhen1 on 10/13/23.
//

#if canImport(simd)

    import simd
    extension simd_double2: VectorLike {

        @inlinable public func lengthSquared() -> Double {
            return x * x + y * y
        }

        @inlinable public func length() -> Double {
            return (x * x + y * y).squareRoot()
        }

        @inlinable public func distanceSquared(to: SIMD2<Scalar>) -> Scalar {
            return (self - to).lengthSquared()
        }

        @inlinable public func distance(to: SIMD2<Scalar>) -> Scalar {
            return (self - to).length()
        }
        
        
        public static let directionCount = 4
    }

    extension simd_double3: VectorLike {

        @inlinable public func lengthSquared() -> Double {
            return x * x + y * y + z * z
        }

        @inlinable public func length() -> Double {
            return (x * x + y * y + z * z).squareRoot()
        }

        @inlinable public func distanceSquared(to: SIMD3<Scalar>) -> Scalar {
            return (self - to).lengthSquared()
        }

        @inlinable public func distance(to: SIMD3<Scalar>) -> Scalar {
            return (self - to).length()
        }
        
        public static let directionCount = 8
    }




    public typealias Vector2d = simd_double2
    public typealias Vector3d = simd_double3

    public protocol QuadtreeDelegate: NDTreeDelegate where V == Vector2d {}
    public protocol OctreeDelegate: NDTreeDelegate where V == Vector3d {}


    public typealias QuadBox = NDBox<Vector2d>
    public typealias OctBox = NDBox<Vector3d>

    public typealias Quadtree<TD: QuadtreeDelegate> = NDTree<Vector2d, TD>
    public typealias Octree<TD: OctreeDelegate> = NDTree<Vector3d, TD>


//    extension simd_double4: VectorLike {
//
//        @inlinable public func lengthSquared() -> Double {
//            return x * x + y * y + z * z + w * w
//        }
//
//        @inlinable public func length() -> Double {
//            return (x * x + y * y + z * z + w * w).squareRoot()
//        }
//
//        @inlinable public func distanceSquared(to: SIMD4<Scalar>) -> Scalar {
//            return (self - to).lengthSquared()
//        }
//
//        @inlinable public func distance(to: SIMD4<Scalar>) -> Scalar {
//            return (self - to).length()
//        }
//    }
//    public typealias Vector4d = simd_double4
//    public protocol HyperoctreeDelegate: NDTreeDelegate where V == Vector4d, Node == Int {}
//    public typealias HyperoctBox = NDBox<Vector4d>
//    public typealias Hyperoctree<TD: HyperoctreeDelegate> = NDTree<Vector4d, TD>



    public extension QuadBox {
        static func createBy(covering point: V) -> Self {
            
            var p0 = V.zero
            var p1 = V.zero
            
            for i in point.indices {
                p0[i] = floor(point[i])
                p1[i] = ceil(point[i])
                
                if p0[i]==p1[i] || point[i] == p1[i] {
                    p1[i] += 1
                }
            }
            return Self(p0, p1)
        }
    }


#endif
