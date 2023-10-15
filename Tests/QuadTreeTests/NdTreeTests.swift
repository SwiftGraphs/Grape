import XCTest
@testable import QuadTree
import simd



struct EmptyTreeDelegate: CompactQuadTreeDelegate {
    typealias V = Vector2d
    var count: Int
    
    mutating func didAddNode(_ node: Int, at position: V) {
        count += 1
    }
    
    mutating func didRemoveNode(_ node: Int, at position: V) {
        count -= 1
    }
    
    func copy() -> EmptyTreeDelegate {
        return Self(count: self.count)
    }
    
    func spawn() -> EmptyTreeDelegate {
        return Self(count: 0)
    }
}


struct EmptyTreeDelegate3D: CompactOctTreeDelegate {
    
    typealias V = Vector3d
    var count: Int
    
    mutating func didAddNode(_ node: Int, at position: V) {
        count += 1
    }
    
    mutating func didRemoveNode(_ node: Int, at position: V) {
        count -= 1
    }
    
    func copy() -> Self {
        return Self(count: self.count)
    }
    
    func spawn() -> Self {
        return Self(count: 0)
    }
    
}

typealias DummyQuadTree = CompactQuadTree<EmptyTreeDelegate>
typealias DummyOctTree = CompactOctTree<EmptyTreeDelegate3D>



struct StupidTreeDelegate: NdTreeDelegate {
    
    var count: [Int: Int] = [:]
    
    mutating func didAddNode(_ nodeIndex: NodeIndex, at position: Vector2d, in indexOfBoxStorage: BoxStorageIndex) {
        count[indexOfBoxStorage, default: 0] += 1
    }
    
    mutating func didRemoveNode(_ nodeIndex: NodeIndex, at position: Vector2d, in indexOfBoxStorage: BoxStorageIndex) {
        count[indexOfBoxStorage, default: 0] -= 1
    }
    
    typealias Coordinate = Vector2d
    
    
}


typealias StupidQuadTree = NdTree<Vector2d,StupidTreeDelegate>



final class NdTreeTests: XCTestCase {
    
//    func testNdBoxSwap() {
//        let box = NdBox(p0: SIMD3<Double>.one, p1: SIMD3<Double>.zero)
//        assert(box.p0 == .zero)
//    }
//    
//    func testNdBoxGetCorner() {
//        let box = NdBox(p0: SIMD3<Double>.one, p1: SIMD3<Double>.zero)
//        let direction = 3
//        assert(box.getCorner(of: direction) == .init(1, 1, 0))
//        let direction2 = 4
//        assert(box.getCorner(of: direction2) == .init(0, 0, 1))
//    }
//    
//    
    func buildTestTree(
        _ p0: simd_double2,
        _ p1: simd_double2,
        _ points: [simd_double2]
    ) -> DummyQuadTree {
        var del = EmptyTreeDelegate(count:0)
        var t = DummyQuadTree(box: .init(p0, p1), clusterDistance: 1e-5, parentDelegate: &del)
        for i in points.indices {
            t.add(i, at: points[i])
        }
        return t
    }
    
    func buildTestTree3D(
        _ p0: Vector3d,
        _ p1: Vector3d,
        _ points: [Vector3d]
    ) -> DummyOctTree {
        var del = EmptyTreeDelegate3D(count:0)
        var t = DummyOctTree(box: .init(p0, p1), clusterDistance: 1e-5, parentDelegate: &del)
        for i in points.indices {
            t.add(i, at: points[i])
        }
        return t
    }
    
    func test2DCreatePoint() {
        
        var t = buildTestTree([0,0], [1,1], [
            [1,2]
        ])
        assert(t.extent ~= QuadBox([0,0], [4,4]))
        
        
        
        
        var t2 = buildTestTree([0,0], [1,1], [
            [0,0],
            [2,2],
            [3,3]
        ])
        
        assert(t2.extent ~= QuadBox([0,0], [4,4]))
        
        
        var t3 = buildTestTree([0,0], [1,1], [
            [0,0],
            [2,2],
            [-1,3]
        ])
        assert(t3.extent ~= QuadBox([-4,0], [4,8]))
        
        
        
        var t4 = buildTestTree([0,0], [1,1], [
            [0,0],
            [2,2],
            [3,-1]
        ])
        
        assert(t4.extent ~= QuadBox([0,-4], [8,4]))
        
        
        var t5 = buildTestTree([0, 0], [1,1], [
            [0, 0],
            [2, 2],
            [-1,-1]
        ])
        assert(t5.extent ~= QuadBox([-4,-4], [4,4]))
    }
    
//    func testRandomTree() {
//        var randomPoints = Array(repeating:simd_double2.zero, count:100)
//        for i in randomPoints.indices {
//            randomPoints[i] = [Double.random(in: -1000...1000), Double.random(in: -1000...1000)]
//        }
//        
////        let r = buildTestTree([-1200,-1200], [1200,1200], randomPoints)
////        assert(r.delegate.count[1]!+r.delegate.count[2]!+r.delegate.count[3]!+r.delegate.count[4]! == 10000)
////        
//        measure {
//            let r = buildTestTree([-1200,-1200], [1200,1200], randomPoints)
//        }
//        
//        
//    }
    
//    func testSimdMask() {
//        let sim = SIMDMask<SIMD2<Double>.MaskStorage>([true,true])
//        var v = simd_double2.zero
//        let v2 = simd_double2.one
//        v.replace(with: [5,6], where: sim)
//        assert(v.y==1)
//    }
    
    

    
//    func testRandomTree3D() {
//        var randomPoints = Array(repeating:Vector3d.zero, count:1000)
//        for i in randomPoints.indices {
//            randomPoints[i] = [
//                Double.random(in: -1000...1000),
//                Double.random(in: -1000...1000),
//                Double.random(in: -1000...1000)
//            ]
//        }
//        
//        measure {
//            for i in 0..<120 {
//                buildTestTree3D([-1200,-1200, -1200], [1200,1200, 1200], randomPoints)
//            }
//        }
//    }
    
    
    
//    func testRandomTree2() {
//        var randomPoints = Array(repeating:Vector2d.zero, count:2000)
//        for i in randomPoints.indices {
//            randomPoints[i] = [Double.random(in: -1000...1000), Double.random(in: -1000...1000)]
//        }
//        
//        measure {
//            for i in 0..<120 {
//                buildTestTree([-1200,-1200], [1200,1200], randomPoints)
//            }
//        }
//    }
    
    
    
    func testQuadTree2() {
        var randomPoints = Array(repeating:Vector2f.zero, count:10000)
        for i in randomPoints.indices {
            randomPoints[i] = [
                Double.random(in: -1000...1000),
                Double.random(in: -1000...1000)
            ]
        }
        


        measure {
            for i in 0..<120 {
                let t = QuadTree2.init(quad: .init(x0: -1200, x1: 1200, y0: -1200, y1: 1200)) {
                    EmptyQuadDelegate()
                }
//                buildTestTree3D([-1200,-1200, -1200], [1200,1200, 1200], randomPoints)
                for j in randomPoints.indices {
                    t.add(.new(), at: randomPoints[j])
                }
            }
        }
    }
    
    
    func testNDTree() {
        var randomPoints = Array(repeating:Vector2d.zero, count:10000)
        for i in randomPoints.indices {
            randomPoints[i] = [
                Double.random(in: -1000...1000),
                Double.random(in: -1000...1000)
            ]
        }

        measure {
            
            for i in 0..<120 {
                let t = StupidQuadTree(initialBox: .init(p0: [-1200,-1200], p1: [1200,1200]), estimatedNodeCount: 10000, clusterDistance: 1e-5)
//                buildTestTree3D([-1200,-1200, -1200], [1200,1200, 1200], randomPoints)
                for j in randomPoints.indices {
                    t.add(at: randomPoints[j])
                }
            }
        }
    }
    
    
    
    func testNDTree2() {
        var randomPoints = Array(repeating:Vector2d.zero, count:10000)
        for i in randomPoints.indices {
            randomPoints[i] = [
                Double.random(in: -1000...1000),
                Double.random(in: -1000...1000)
            ]
        }

        measure {
            
            for i in 0..<120 {
                var del = EmptyTreeDelegate(count: 0)
                let t = DummyQuadTree(box: .init(p0: [-1200,-1200], p1: [1200,1200]), clusterDistance: 1e-5, parentDelegate: &del)
//                buildTestTree3D([-1200,-1200, -1200], [1200,1200, 1200], randomPoints)
                for j in randomPoints.indices {
                    t.add(j, at: randomPoints[j])
                }
            }
        }
        
        
    }

}
