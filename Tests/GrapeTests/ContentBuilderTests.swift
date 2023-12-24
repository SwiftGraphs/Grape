import SwiftUI
import XCTest
import simd

@testable import Grape

final class ContentBuilderTests: XCTestCase {
    func buildGraph<NodeID>(
        @GraphContentBuilder<NodeID> _ builder: () -> some GraphContent<NodeID>
    ) -> some GraphContent where NodeID: Hashable {
        let result = builder()
        return result
    }

    func testSyntaxes() {

        struct ID: Identifiable {
            var id: Int
        }

        let arr = [
            ID(id: 0),
            ID(id: 1),
            ID(id: 2),
        ]

        let a = ForEach(data: arr) { i in
            NodeMark(id: i.id)
        }

        let b = buildGraph {
            NodeMark(id: 0)
            ForEach(data: arr) { i in
                NodeMark(id: i.id)
            }
        }

        let c = buildGraph {
            NodeMark(id: 0)
            for i in 0..<10 {
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
    }

    func testForLoop() {
        let _ = buildGraph {
            for i in 0..<10 {
                NodeMark(id: i)
            }
        }
    }

    func testMixed() {
        let _ = buildGraph {
            LinkMark(from: 0, to: 1)
            NodeMark(id: 3)
            NodeMark(id: 4)
            NodeMark(id: 5)
        }
    }

    func testConditional() {
        let _ = buildGraph {
            if true {
                NodeMark(id: 0)
            } else {
                NodeMark(id: 1)
            }
        }
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

        let _ = buildGraph {
            ForEach(data: arr) { i in
                NodeMark(id: i.id)
            }
        }
    }
}
