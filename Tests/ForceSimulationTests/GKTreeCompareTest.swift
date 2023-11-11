//
//  File.swift
//
//
//  Created by li3zhen1 on 10/4/23.
//

import GameKit
import XCTest

// import ForceSimulation
@testable import ForceSimulation

struct DummyQuadtreeDelegate: KDTreeDelegate {
    @inlinable
    mutating func didAddNode(_ node: Int, at position: SIMD2<Double>) {
        count += 1
    }

    @inlinable
    mutating func didRemoveNode(_ node: Int, at position: SIMD2<Double>) {
        count -= 1
    }

    @inlinable
    func copy() -> Self {
        return Self(count: count)
    }

    @inlinable
    func spawn() -> Self {
        return Self(count: 0)
    }

    var count = 0

    init(count: Int = 0) {
        self.count = count
    }

}

struct NamedNode: Identifiable {
    let name: String
    let id: Int

    static var count = 0
    static func make(_ name: String) -> NamedNode {
        defer { count += 1 }
        return NamedNode(name: name, id: count)
    }
}

final class ManyBodyForceTests: XCTestCase {
    func test() {
        // randomly generate 100000 nodes in [-100, 100] x [-100, 100]
        let nodes: [simd_float2] = (0..<100000).map { _ in
            let x = Float.random(in: -100...100)
            let y = Float.random(in: -100...100)
            return simd_float2(x, y)
        }

        measure {
            let gkTree = GKQuadtree<NSNumber>(
                boundingQuad: .init(quadMin: [-100.0, -100.0], quadMax: [100.0, 100.0]),
                minimumCellSize: 1e-5
            )

            for (i, node) in nodes.enumerated() {
                gkTree.add(NSNumber(value: i), at: node)
            }

            // traverse the tree
            var count = 0
            gkTree.elements(in: .init(quadMin: [-100.0, -100.0], quadMax: [100.0, 100.0]))
                .forEach { _ in count += 1 }
            XCTAssertEqual(count, nodes.count)
        }
    }

    func testGrapeKDTre() {
        let nodes: [simd_double2] = (0..<100000).map { _ in
            let x = Double.random(in: -100...100)
            let y = Double.random(in: -100...100)
            return simd_double2(x, y)
        }

        measure {
            var kdtree = KDTree<SIMD2<Double>,DummyQuadtreeDelegate>(
                box: .init([-100.0,-100.0], [100.0,100.0]),
                spawnedDelegateBeingConsumed: DummyQuadtreeDelegate()
            )

            for (i, node) in nodes.enumerated() {
                kdtree.add(i, at: node)
            }

            // traverse the tree
            var count = 0
            kdtree.visit { t in
                if t.isLeaf {
                    count += t.delegate.count
                    return false
                }
                return true
            }
            XCTAssertEqual(count, nodes.count)
        }
    }
}
