import XCTest
@testable import QuadTree
import simd

struct EmptyTreeDelegate: NdTreeDelegate {
    typealias Coordinate = simd_double2
    
    mutating func didAddNode(_ nodeIndex: Int, at position: Coordinate) {
        
    }
    
    mutating func didRemoveNode(_ nodeIndex: Int, at position: Coordinate) {
        
    }
    
    typealias Index = Int
}

typealias DummyQuadTree = CompactQuadTree<EmptyTreeDelegate>

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
        let t = DummyQuadTree(initialBox: .init(p0, p1), estimatedNodeCount: points.count, clusterDistance: 1e-5)
        for i in points.indices {
            t.add(i, at:points[i])
        }
        return t
    }
    
    func test2DCreatePoint() {
        

        
        
        let t = DummyQuadTree(initialBox: .init([0,0], [1,1]), estimatedNodeCount: 2, clusterDistance: 1e-5)
        t.add(0, at: [1,2])
        
        assert(t.rootBox ~= QuadBox(p0:[0,0], p1:[4,4]))
        
        
        let t2 = DummyQuadTree(initialBox: .init([0,0], [1,1]), estimatedNodeCount: 2, clusterDistance: 1e-5)
        t2.add(0, at: [0,0])
        t2.add(1, at: [2,2])
        t2.add(2, at: [3,3])
        
        assert(t2.rootBox ~= QuadBox([0,0], [4,4]))
        
        
        
        let t3 = DummyQuadTree(initialBox: .init([0,0], [1,1]), estimatedNodeCount: 3, clusterDistance: 1e-5)
        t3.add(0, at: [0,0])
        t3.add(1, at: [2,2])
        t3.add(2, at: [-1,3])
        
        assert(t3.rootBox ~= QuadBox([-4,0], [4,8]))
        
        
        let t4 = DummyQuadTree(initialBox: .init([0,0], [1,1]), estimatedNodeCount: 3, clusterDistance: 1e-5)
        t4.add(0, at: [0,0])
        t4.add(1, at: [2,2])
        t4.add(2, at: [3,-1])
        
        assert(t4.rootBox ~= QuadBox([0,-4], [8,4]))
        
        
        let t5 = buildTestTree([0, 0], [1,1], [
            [0, 0],
            [2, 2],
            [-1,-1]
        ])
        assert(t5.rootBox ~= QuadBox([-4,-4], [4,4]))
    }
}
