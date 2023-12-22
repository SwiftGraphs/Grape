
import XCTest
import simd
import SwiftUI

@testable import Grape



final class ContentBuilderTests: XCTestCase {
    func buildGraph<NodeID>(
        @GraphContentBuilder<NodeID> _ builder: () -> some GraphContent<NodeID>
    ) -> some GraphContent where NodeID: Hashable {
        let result = builder()
        return result
    }

    func testFullyConnected() {
        let _ = buildGraph {
            FullyConnected {
                NodeMark(id: 0)
                NodeMark(id: 1)
                NodeMark(id: 2)
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
            FullyConnected {
                NodeMark(id: 0)
                NodeMark(id: 1)
                NodeMark(id: 2)
            }
            NodeMark(id: 3)
            NodeMark(id: 4)
            NodeMark(id: 5)
        }
    }

    func testConditional() {
        // let _ = buildGraph {
        //     if true {
        //         NodeMark(id: 0)
        //     } else {
        //         NodeMark(id: 1)
        //     }
        // }
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

        // let _ = buildGraph {
        //     ForEach(data: arr) { i in
        //         NodeMark(id: i.id)
        //     }
        // }
    }
}