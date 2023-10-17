import XCTest
@testable import NDTree
import simd


final class DummyQuadtreeDelegate: QuadtreeDelegate {
    func didAddNode(_ node: Int, at position: SIMD2<Double>) {
        count += 1
    }
    
    func didRemoveNode(_ node: Int, at position: SIMD2<Double>) {
        count -= 1
    }
    
    func copy() -> Self {
        return Self(count:count)
    }
    
    func spawn() -> Self {
        return Self(count:0)
    }
    
    var count = 0
    
    init(count: Int = 0) {
        self.count = count
    }
    
}



final class AddTests: XCTestCase {

    // tests below are mainly generate by github copilot with d3 source code
    private func t(
        _ points: [Vector2d]
    ) -> Quadtree<DummyQuadtreeDelegate> {
        var del = DummyQuadtreeDelegate()
        let box = QuadBox.createBy(covering: points[0])
        let qt = Quadtree(box: box, parentDelegate: /*&*/del)
        for i in points.indices {
            qt.add(i, at: points[i])
        }
        return qt
    }

    private func t(
        _ box: QuadBox,
        _ points: [Vector2d]
    ) -> Quadtree<DummyQuadtreeDelegate> {
        var del = DummyQuadtreeDelegate()
        let qt = Quadtree(box: box, parentDelegate: /*&*/del)
        for i in points.indices {
            qt.add(i, at: points[i])
        }
        
        return qt
    }
    
    
    func testCreatePoint() {
        let q = t([[0, 0]])
        assert(q.debugDescription ~= "{data: [0.0, 0.0]}")

        q.add(1, at: [0.9, 0.9])
        assert(q.debugDescription ~= "[{data: [0.0, 0.0]},,, {data: [0.9, 0.9]}]")

        q.add(2, at: [0.9, 0.0])
        assert(q.debugDescription ~= "[{data: [0.0, 0.0]}, {data: [0.9, 0.0]},, {data: [0.9, 0.9]}]")

        q.add(3, at: [0.0, 0.9])
        assert(q.debugDescription ~= "[{data: [0.0, 0.0]}, {data: [0.9, 0.0]}, {data: [0.0, 0.9]}, {data: [0.9, 0.9]}]")

        q.add(4, at: [0.4, 0.4])
        assert(q.debugDescription ~= "[[{data: [0.0, 0.0]},,, {data: [0.4, 0.4]}], {data: [0.9, 0.0]}, {data: [0.0, 0.9]}, {data: [0.9, 0.9]}]")
    }


    func testCreatePointOnPerimeter() {
        let q = t([[0, 0]])
        assert(q.debugDescription ~= "{data: [0.0, 0.0]}")
        assert(q.delegate.count == 1)

        q.add(1, at: [1, 1])
        assert(q.debugDescription ~= "[{data: [0.0, 0.0]},,, {data: [1.0, 1.0]}]")
        assert(q.delegate.count == 2)

        q.add(2, at: [1, 0])
        assert(q.debugDescription ~= "[{data: [0.0, 0.0]}, {data: [1.0, 0.0]},, {data: [1.0, 1.0]}]")
        assert(q.delegate.count == 3)

        q.add(3, at: [0, 1])
        assert(q.debugDescription ~= "[{data: [0.0, 0.0]}, {data: [1.0, 0.0]}, {data: [0.0, 1.0]}, {data: [1.0, 1.0]}]")
        assert(q.delegate.count == 4)
    }


    func testCreatePointOnTop() {
        let q = t(QuadBox([0,0], [2,2]), [[0, 0], [1, -1]])
        assert(q.debugDescription ~= "[{data: [1.0, -1.0]},,{data: [0.0, 0.0]},]")
        assert(q.delegate.count == 2)
        assert(q.extent.p0 ~= [0,-2])
        assert(q.extent.p1 ~= [4,2])
    }


    func testCreatePointOnBottom() {
        let q = t(QuadBox([0,0], [2,2]), [[0, 0], [1, 3]])
        assert(q.delegate.count == 2)
        assert(q.extent.p0 ~= [0,0])
        assert(q.extent.p1 ~= [4,4])
    }


    func testCreatePointOnLeft() {
        let q = t(QuadBox([0,0], [2,2]), [[0, 0], [-1, 1]])
        assert(q.delegate.count == 2)
        assert(q.extent.p0 ~= [-2,0])
        assert(q.extent.p1 ~= [2,4])
    }


    func testCreateCoincidentPoints() {
        let q = t(QuadBox([0,0], [1,1]), [[0, 0], [1, 0], [0, 1], [0, 1]])
        assert(q.children![2].nodeIndices.count == 2)
        assert(q.delegate.count == 4)
    }


    
    func testCreateFirstPoint() {
        let q = t(QuadBox([1,2], [2,3]), [[1, 2]])
        assert(q.extent.p0 ~= [1,2])
        assert(q.extent.p1 ~= [2,3])
        assert(q.debugDescription ~= "{data: [1.0, 2.0]}")
        assert(q.delegate.count == 1)
    }
    
}
