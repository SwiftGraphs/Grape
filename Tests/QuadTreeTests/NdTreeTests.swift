import XCTest
@testable import QuadTree
import simd

struct EmptyTreeDelegate: CompactQuadTreeDelegate {
    
    var count: [Int:Int] = [:]
    
    mutating func didAddNode(
        _ nodeIndex: NodeIndex,
        at position: simd_double2,
        in indexOfBoxStorage: BoxStorageIndex
    ) {
        count[indexOfBoxStorage, default: 0] += 1
    }
    
    mutating func didRemoveNode(
        _ nodeIndex: NodeIndex,
        at position: simd_double2,
        in indexOfBoxStorage: BoxStorageIndex
    ) {
        count[indexOfBoxStorage, default: 0] -= 1
    }
    
    typealias Coordinate = Vector2d
}


struct EmptyTreeDelegate3D: CompactOctTreeDelegate {
    
    var count: [Int:Int] = [:]
    
    mutating func didAddNode(
        _ nodeIndex: NodeIndex,
        at position: Coordinate,
        in indexOfBoxStorage: BoxStorageIndex
    ) {
        count[indexOfBoxStorage, default: 0] += 1
    }
    
    mutating func didRemoveNode(
        _ nodeIndex: NodeIndex,
        at position: Coordinate,
        in indexOfBoxStorage: BoxStorageIndex
    ) {
        count[indexOfBoxStorage, default: 0] -= 1
    }
    
    typealias Coordinate = Vector3d
}

typealias DummyQuadTree = CompactQuadTree<EmptyTreeDelegate>
typealias DummyOctTree = CompactOctTree<EmptyTreeDelegate3D>

final class NdTreeTests: XCTestCase {
    
    func testNdBoxSwap() {
        let box = NdBox(p0: SIMD3<Double>.one, p1: SIMD3<Double>.zero)
        assert(box.p0 == .zero)
    }
    
    func testNdBoxGetCorner() {
        let box = NdBox(p0: SIMD3<Double>.one, p1: SIMD3<Double>.zero)
        let direction = 3
        assert(box.getCorner(of: direction) == .init(1, 1, 0))
        let direction2 = 4
        assert(box.getCorner(of: direction2) == .init(0, 0, 1))
    }
    
    
    func buildTestTree(
        _ p0: simd_double2,
        _ p1: simd_double2,
        _ points: [simd_double2]
    ) -> DummyQuadTree {
        var t = DummyQuadTree(initialBox: .init(p0, p1), estimatedNodeCount: points.count, clusterDistance: 1e-5)
        t.addAll(points)
        return t
    }
    
    func buildTestTree3D(
        _ p0: Vector3d,
        _ p1: Vector3d,
        _ points: [Vector3d]
    ) -> DummyOctTree {
        var t = DummyOctTree(initialBox: .init(p0, p1), estimatedNodeCount: points.count, clusterDistance: 1e-5)
        t.addAll(points)
        return t
    }
    
    func test2DCreatePoint() {
        

        
        
        var t = DummyQuadTree(initialBox: .init([0,0], [1,1]), estimatedNodeCount: 2, clusterDistance: 1e-5)
        t.add(at: [1,2])
        
        assert(t.extent ~= QuadBox([0,0], [4,4]))
        
        
        var t2 = DummyQuadTree(initialBox: .init([0,0], [1,1]), estimatedNodeCount: 2, clusterDistance: 1e-5)
        t2.add(at: [0,0])
        t2.add(at: [2,2])
        t2.add(at: [3,3])
        
        assert(t2.extent ~= QuadBox([0,0], [4,4]))
        
        
        
        var t3 = DummyQuadTree(initialBox: .init([0,0], [1,1]), estimatedNodeCount: 3, clusterDistance: 1e-5)
        t3.add(at: [0,0])
        t3.add(at: [2,2])
        t3.add(at: [-1,3])
        
        assert(t3.extent ~= QuadBox([-4,0], [4,8]))
        
        
        var t4 = DummyQuadTree(initialBox: .init([0,0], [1,1]), estimatedNodeCount: 3, clusterDistance: 1e-5)
        t4.add(at: [0,0])
        t4.add(at: [2,2])
        t4.add(at: [3,-1])
        
        assert(t4.extent ~= QuadBox([0,-4], [8,4]))
        
        
        var t5 = buildTestTree([0, 0], [1,1], [
            [0, 0],
            [2, 2],
            [-1,-1]
        ])
        assert(t5.extent ~= QuadBox([-4,-4], [4,4]))
    }
    
    func testRandomTree() {
        var randomPoints = Array(repeating:simd_double2.zero, count:10000)
        for i in randomPoints.indices {
            randomPoints[i] = [Double.random(in: -1000...1000), Double.random(in: -1000...1000)]
        }
        
//        let r = buildTestTree([-1200,-1200], [1200,1200], randomPoints)
//        assert(r.delegate.count[1]!+r.delegate.count[2]!+r.delegate.count[3]!+r.delegate.count[4]! == 10000)
//        
        measure {
            let r = buildTestTree([-1200,-1200], [1200,1200], randomPoints)
        }
        
        
    }
    
//    func testSimdMask() {
//        let sim = SIMDMask<SIMD2<Double>.MaskStorage>([true,true])
//        var v = simd_double2.zero
//        let v2 = simd_double2.one
//        v.replace(with: [5,6], where: sim)
//        assert(v.y==1)
//    }
    
    
    func testRandomTree2() {
        var randomPoints = Array(repeating:Vector2d.zero, count:1000)
        for i in randomPoints.indices {
            randomPoints[i] = [Double.random(in: -1000...1000), Double.random(in: -1000...1000)]
        }
        
        measure {
            for i in 0..<120 {
                buildTestTree([-1200,-1200], [1200,1200], randomPoints)
            }
        }
    }
    
    
    func testRandomTree3D() {
        var randomPoints = Array(repeating:Vector3d.zero, count:1000)
        for i in randomPoints.indices {
            randomPoints[i] = [
                Double.random(in: -1000...1000),
                Double.random(in: -1000...1000),
                Double.random(in: -1000...1000)
            ]
        }
        
        measure {
            for i in 0..<120 {
                buildTestTree3D([-1200,-1200, -1200], [1200,1200, 1200], randomPoints)
            }
        }
    }

}
