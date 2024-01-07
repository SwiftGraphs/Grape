import SwiftUI
import XCTest
import simd

@testable import Grape

func buildGraph<NodeID>(
    @GraphContentBuilder<NodeID> _ builder: () -> some GraphContent<NodeID>
) -> some GraphContent<NodeID> where NodeID: Hashable {
    let result = builder()
    return result
}

final class GraphContentBuilderTests: XCTestCase {

    func testSyntaxes() {

        struct ID: Identifiable {
            var id: Int
        }

        let arr = [
            ID(id: 0),
            ID(id: 1),
            ID(id: 2),
        ]

        let a = Series(arr) { i in
            NodeMark(id: i.id)
        }

        let b = buildGraph {
            NodeMark(id: 0)
            Series(arr) { i in
                NodeMark(id: i.id)
            }
        }

        let c = buildGraph {
            NodeMark(id: 0)
            Series(0..<10) { i in
                NodeMark(id: 0)
            }
        }

        var t = 1
        let d = buildGraph {
            if true {
                NodeMark(id: 0)
                for i in 0..<10 {
                    NodeMark(id: 0)
                }
            } else {
                LinkMark(from: 0, to: 1)
                NodeMark(id: 0)
            }

            if t == 1 {
                LinkMark(from: 0, to: 1)
            }
        }

        var gc = _GraphRenderingContext<Int>()
        d._attachToGraphRenderingContext(&gc)

        XCTAssert(
            gc.nodes.count == 11,
            "Expected 1 node, got \(gc.nodes.count)"
        )
    }

    func testForLoop() {
        let gc = buildGraph {
            for i in 0..<10 {
                NodeMark(id: i)
            }
        }

        var ctx = _GraphRenderingContext<Int>()

        gc._attachToGraphRenderingContext(&ctx)

        XCTAssert(
            ctx.nodes.count == 10,
            "Expected 10 nodes, got \(ctx.nodes.count)"
        )
    }

    func testMixed() {
        let gc = buildGraph {
            LinkMark(from: 0, to: 1)
            NodeMark(id: 3)
            NodeMark(id: 4)
            NodeMark(id: 5)
        }

        var ctx = _GraphRenderingContext<Int>()

        gc._attachToGraphRenderingContext(&ctx)

        XCTAssert(
            ctx.nodes.count == 3,
            "Expected 3 nodes, got \(ctx.nodes.count)"
        )

        XCTAssert(
            ctx.edges.count == 1,
            "Expected 1 edge, got \(ctx.edges.count)"
        )

        XCTAssert(
            ctx.nodes[0].id == 3)

        XCTAssert(
            ctx.nodes[1].id == 4)

        XCTAssert(
            ctx.nodes[2].id == 5)

    }

    func testConditional() {
        let gc = buildGraph {
            if true {
                NodeMark(id: 0)
                    .foregroundStyle(.red)
                    // .opacity(0.2)
            } else {
                NodeMark(id: 1)
            }
        }

        var ctx = _GraphRenderingContext<Int>()

        gc._attachToGraphRenderingContext(&ctx)

        XCTAssert(
            ctx.nodes.count == 1,
            "Expected 1 node, got \(ctx.nodes.count)"
        )

        XCTAssert(
            ctx.nodes[0].id == 0,
            "Expected 0 edges, got \(ctx.edges.count)"
        )

        XCTAssert(
            ctx.edges.count == 0,
            "Expected 0 edges, got \(ctx.edges.count)"
        )

    }

    struct ID: Identifiable {
        var id: Int
    }

    func testForEach() {
        let arr = [
            ID(id: 0),
            ID(id: 1),
            ID(id: 2),
        ]

        let gc = buildGraph {
            ForEach(arr) { i in
                NodeMark(id: i.id)
                    // .opacity(0.2)
            }
        }

        var ctx = _GraphRenderingContext<Int>()
        gc._attachToGraphRenderingContext(&ctx)

        XCTAssert(
            ctx.nodes.count == 3,
            "Expected 3 nodes, got \(ctx.nodes.count)"
        )

    }

    struct MyGraphComponent: GraphComponent {
        typealias NodeID = Int
        var body: some GraphContent<Int> {
            NodeMark(id: 0)
                // .opacity(0.6)
            NodeMark(id: 1)
            NodeMark(id: 2)
        }
    }

    func testCustomComponent() {
        let gc = buildGraph {
            MyGraphComponent()
                // .opacity(0.2)
        }

        var ctx = _GraphRenderingContext<Int>()
        gc._attachToGraphRenderingContext(&ctx)

        XCTAssert(
            ctx.nodes.count == 3,
            "Expected 3 nodes, got \(ctx.nodes.count)"
        )
    }
}
