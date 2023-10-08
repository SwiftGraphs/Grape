import XCTest
@testable import QuadTree






final class AddTests: XCTestCase {

    // tests below are mainly generate by github copilot with d3 source code
    
    /*
     it("quadtree.add(datum) creates a new point and adds it to the quadtree", () => {
       const q = quadtree();
       assert.deepStrictEqual(q.add([0.0, 0.0]).root(), {data: [0, 0]});
       assert.deepStrictEqual(q.add([0.9, 0.9]).root(), [{data: [0, 0]},,, {data: [0.9, 0.9]}]);
       assert.deepStrictEqual(q.add([0.9, 0.0]).root(), [{data: [0, 0]}, {data: [0.9, 0]},, {data: [0.9, 0.9]}]);
       assert.deepStrictEqual(q.add([0.0, 0.9]).root(), [{data: [0, 0]}, {data: [0.9, 0]}, {data: [0, 0.9]}, {data: [0.9, 0.9]}]);
       assert.deepStrictEqual(q.add([0.4, 0.4]).root(), [[{data: [0, 0]},,, {data: [0.4, 0.4]}], {data: [0.9, 0]}, {data: [0, 0.9]}, {data: [0.9, 0.9]}]);
     });
    */
    func testCreatePoint() {
        let q = QuadTree<IdNode>.create(startingWith: IdNode.new(), at: Vector2f(x: 0, y:0))
        assert(q.jsStyleDescription ~= "{data: [0.0, 0.0]}")
        
        q.add(IdNode.new(), at: Vector2f(x: 0.9, y:0.9))
        assert(q.jsStyleDescription ~= "[{data: [0.0, 0.0]},,, {data: [0.9, 0.9]}]")
        
        q.add(IdNode.new(), at: Vector2f(x: 0.9, y:0.0))
        assert(q.jsStyleDescription ~= "[{data: [0.0, 0.0]}, {data: [0.9, 0.0]},, {data: [0.9, 0.9]}]")
        
        q.add(IdNode.new(), at: Vector2f(x: 0.0, y:0.9))
        assert(q.jsStyleDescription ~= "[{data: [0.0, 0.0]}, {data: [0.9, 0.0]}, {data: [0.0, 0.9]}, {data: [0.9, 0.9]}]")
        
        q.add(IdNode.new(), at: Vector2f(x: 0.4, y:0.4))
        assert(q.jsStyleDescription ~= "[[{data: [0.0, 0.0]},,, {data: [0.4, 0.4]}], {data: [0.9, 0.0]}, {data: [0.0, 0.9]}, {data: [0.9, 0.9]}]")
        
    }

    
    /*
    it("quadtree.add(datum) handles points being on the perimeter of the quadtree bounds", () => {
  const q = quadtree().extent([[0, 0], [1, 1]]);
  assert.deepStrictEqual(q.add([0, 0]).root(), {data: [0, 0]});
  assert.deepStrictEqual(q.add([1, 1]).root(), [{data: [0, 0]},,, {data: [1, 1]}]);
  assert.deepStrictEqual(q.add([1, 0]).root(), [{data: [0, 0]}, {data: [1, 0]},, {data: [1, 1]}]);
  assert.deepStrictEqual(q.add([0, 1]).root(), [{data: [0, 0]}, {data: [1, 0]}, {data: [0, 1]}, {data: [1, 1]}]);
});

    */
    func testCreatePointOnPerimeter() {
        let q = QuadTree<IdNode>(quad: Quad(x0: 0.0, x1: 1.0, y0: 0.0, y1: 1.0))

        q.add(IdNode.new(), at: Vector2f(x: 0, y:0))
        assert(q.jsStyleDescription ~= "{data: [0.0, 0.0]}")
        
        q.add(IdNode.new(), at: Vector2f(x: 1, y:1))
        assert(q.jsStyleDescription ~= "[{data: [0.0, 0.0]},,, {data: [1.0, 1.0]}]")
        
        q.add(IdNode.new(), at: Vector2f(x: 1, y:0))
        assert(q.jsStyleDescription ~= "[{data: [0.0, 0.0]}, {data: [1.0, 0.0]},, {data: [1.0, 1.0]}]")
        
        q.add(IdNode.new(), at: Vector2f(x: 0, y:1))
        assert(q.jsStyleDescription ~= "[{data: [0.0, 0.0]}, {data: [1.0, 0.0]}, {data: [0.0, 1.0]}, {data: [1.0, 1.0]}]")
    }


    // it("quadtree.add(datum) handles points being to the top of the quadtree bounds", () => {
    //     const q = quadtree().extent([[0, 0], [2, 2]]);
    //     assert.deepStrictEqual(q.add([1, -1]).extent(), [[0, -4], [8, 4]]);
    // });
    func testCreatePointOnTop() {
        let q = QuadTree<IdNode>(quad: Quad(x0: 0.0, x1: 2.0, y0: 0.0, y1: 2.0))
        q.add(IdNode.new(), at: Vector2f(x: 1, y:-1))
        assert(q.root.quad ~= Quad(x0: 0, x1: 4, y0: -2, y1: 2))
    }
    


    // it("quadtree.add(datum) handles points being to the bottom of the quadtree bounds", () => {
    // const q = quadtree().extent([[0, 0], [2, 2]]);
    // assert.deepStrictEqual(q.add([1, 3]).extent(), [[0, 0], [4, 4]]);
    // });
    func testCreatePointOnBottom() {
        let q = QuadTree<IdNode>(quad: Quad(x0: 0.0, x1: 2.0, y0: 0.0, y1: 2.0))
        q.add(IdNode.new(), at: Vector2f(x: 1, y:3))
        assert(q.root.quad ~= Quad(x0: 0, x1: 4, y0: 0, y1: 4))
    }

    // it("quadtree.add(datum) handles points being to the left of the quadtree bounds", () => {
    // const q = quadtree().extent([[0, 0], [2, 2]]);
    // assert.deepStrictEqual(q.add([-1, 1]).extent(), [[-4, 0], [4, 8]]);
    // });
    func testCreatePointOnLeft() {
        let q = QuadTree<IdNode>(quad: Quad(x0: 0.0, x1: 2.0, y0: 0.0, y1: 2.0))
        q.add(IdNode.new(), at: Vector2f(x: -1, y:1))
        assert(q.root.quad ~= Quad(x0: -2, x1: 2, y0: 0, y1: 4))
    }

    // it("quadtree.add(datum) handles coincident points by creating a linked list", () => {
    // const q = quadtree().extent([[0, 0], [1, 1]]);
    // assert.deepStrictEqual(q.add([0, 0]).root(), {data: [0, 0]});
    // assert.deepStrictEqual(q.add([1, 0]).root(), [{data: [0, 0]}, {data: [1, 0]},,, ]);
    // assert.deepStrictEqual(q.add([0, 1]).root(), [{data: [0, 0]}, {data: [1, 0]}, {data: [0, 1]},, ]);
    // assert.deepStrictEqual(q.add([0, 1]).root(), [{data: [0, 0]}, {data: [1, 0]}, {data: [0, 1], next: {data: [0, 1]}},, ]);
    // });
    func testCreateCoincidentPoints() {
        let q = QuadTree<IdNode>(quad: Quad(x0: 0.0, x1: 1.0, y0: 0.0, y1: 1.0))
        q.add(IdNode.new(), at: Vector2f(x: 0, y:0))
        assert(q.jsStyleDescription ~= "{data: [0.0, 0.0]}")
        
        q.add(IdNode.new(), at: Vector2f(x: 1, y:0))
        assert(q.jsStyleDescription ~= "[, , {data: [0.0, 0.0]}, {data: [1.0, 0.0]}]")
        
        q.add(IdNode.new(), at: Vector2f(x: 0, y:1))
        assert(q.jsStyleDescription ~= "[, [, , {data: [0.0, 0.0]}, {data: [1.0, 0.0]}], , {data: [0.0, 1.0]}]")
        
        q.add(IdNode.new(), at: Vector2f(x: 0, y:1))
        assert(q.jsStyleDescription ~= "[, [, , {data: [0.0, 0.0]}, {data: [1.0, 0.0]}], , {data: [0.0, 1.0], next:{data: [0.0, 1.0]}}]")
    }

    // it("quadtree.add(datum) implicitly defines trivial bounds for the first point", () => {
    // const q = quadtree().add([1, 2]);
    // assert.deepStrictEqual(q.extent(), [[1, 2], [2, 3]]);
    // assert.deepStrictEqual(q.root(), {data: [1, 2]});
    // });
    func testCreateFirstPoint() {
        let q = QuadTree<IdNode>.create(startingWith: .new(), at: .init(1, 2))

        assert(q.quad ~= Quad(x0: 1, x1: 2, y0: 2, y1: 3))
        assert(q.jsStyleDescription ~= "{data: [1.0, 2.0]}")
    }
}
