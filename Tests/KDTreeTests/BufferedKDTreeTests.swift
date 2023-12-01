import XCTest
@testable import ForceSimulation

struct CountKDTreeDelegate: KDTreeDelegate {
    mutating func didAddNode(_ node: Int, at position: SIMD2<Double>) {
        count += 1
    }
    
    mutating func didRemoveNode(_ node: Int, at position: SIMD2<Double>) {
        count -= 1
    }

    
    typealias NodeID = Int
    
    typealias Vector = SIMD2<Double>
    
    var count = 0
    
    func spawn() -> CountKDTreeDelegate {
        return .init(count: 0)
    }
    
}

class BufferedKDTreeTests: XCTestCase {
    
    private func buildTree(
        box: KDBox<SIMD2<Double>>,
        points: [SIMD2<Double>]
    ) -> BufferedKDTree<SIMD2<Double>, CountKDTreeDelegate> {
        var t = BufferedKDTree(
            rootBox: box,
            nodeCapacity: points.count,
            rootDelegate: CountKDTreeDelegate()
        )
        for i in points.indices {
            t.add(nodeIndex: i, at: points[i])
        }
        return t
    }
    
    func testCorner() {
        
        let t = buildTree(box: .init(p0: [0,0], p1: [1,1]), points: [
            [0,0]
        ])
        
        XCTAssert(t.root.nodeIndices!.index == 0)
        XCTAssert(t.root.childrenBufferPointer == nil)
        XCTAssert(t.root.delegate.count == 1)
    }
    
    func testCorner2() {
        let t = buildTree(box: .init(p0: [0,0], p1: [1,1]), points: [
            [1,1]
        ])
        
        XCTAssert(t.root.nodeIndices == nil)
        XCTAssert(t.root.delegate.count == 1)
        XCTAssert(t.root.childrenBufferPointer![3].delegate.count == 1)
        XCTAssert(t.root.box.p1 == [2, 2])
    }
    
    func testRandomTree() {
        let randomPoints = (0..<1000).map { _ in
            SIMD2<Double>([Double.random(in: 0..<100), Double.random(in: 0..<100)])
        }

        let t = buildTree(box: .init(p0: [0,0], p1: [100,100]), points: randomPoints)
        XCTAssert(t.root.delegate.count == randomPoints.count)
    }
    

}
