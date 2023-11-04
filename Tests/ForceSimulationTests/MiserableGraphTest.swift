//
//  File.swift
//
//
//  Created by li3zhen1 on 10/4/23.
//

import XCTest
// import ForceSimulation
import simd

@testable import ForceSimulation

final class MiserableGraphTest: XCTestCase {

    func test_generic_pack_3d() {
        let data = getData()

        let wrapped = Simulation3D(
            nodeIds: data.nodes.map { n in
                n.id
            }
        )
        .withLinkForce(
            data.links.map({ l in
                (l.source, l.target)
            })
        )
        .withManyBodyForce(strength: -30)
        .withCenterForce(center: .zero)
        .withCollideForce(radius: .constant(5.0))

        measure {
            for i in 0..<120 {
                wrapped.tick()
            }
        }
    }

    func test_generic_pack_2d() {
        let data = getData()

        let wrapped = Simulation2D(
            nodeIds: data.nodes.map { n in
                n.id
            }
        )
        .withLinkForce(
            data.links.map({ l in
                (l.source, l.target)
            })
        )
        .withManyBodyForce(strength: -30)
        .withCenterForce(center: .zero)
        .withCollideForce(radius: .constant(5.0))

        measure {
            for i in 0..<120 {
                wrapped.tick()
            }
        }
    }

}
