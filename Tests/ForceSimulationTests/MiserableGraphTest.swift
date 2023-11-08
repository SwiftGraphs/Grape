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

func getLinks() -> [EdgeID<Int>] {
    let data = getData()
    return data.links.map { l in
        EdgeID(
            source: data.nodes.firstIndex { n in n.id == l.source }!,
            target: data.nodes.firstIndex { n in n.id == l.target }!
        )
    }
}
struct MyForceField: ForceField {

    typealias Vector = SIMD2<Double>

    var force = CompositedForce {

        Kinetics<Vector>.ManyBodyForce(strength: -30)

        Kinetics<Vector>.LinkForce(
            stiffness: .weightedByDegree(k: { _, _ in 1.0 }),
            originalLength: .constant(30)
        )

        Kinetics<Vector>.CenterForce(center: .zero, strength: 1)

        Kinetics<Vector>.CollideForce(radius: .constant(0))

    }
}

struct MyForceField3D: ForceField {

    typealias Vector = SIMD3<Float>

    var force = CompositedForce {

        Kinetics<Vector>.ManyBodyForce(strength: -30)

        Kinetics<Vector>.LinkForce(
            stiffness: .weightedByDegree(k: { _, _ in 1.0 }),
            originalLength: .constant(30)
        )

        Kinetics<Vector>.CenterForce(center: .zero, strength: 1)

        Kinetics<Vector>.CollideForce(radius: .constant(0))

    }
}

final class MiserableGraphTest: XCTestCase {

    func test_generic_pack_2d() {

        let data = getData()

        let simulation = Simulation(
            nodeCount: data.nodes.count,
            links: getLinks(),
            forceField: MyForceField()
        )

        // let wrapped = Simulation2D(
        //     nodeIds: data.nodes.map { n in
        //         n.id
        //     }
        // )
        // .withLinkForce(
        //     data.links.map({ l in
        //         (l.source, l.target)
        //     })
        // )
        // .withManyBodyForce(strength: -30)
        // .withCenterForce(center: .zero)
        // .withCollideForce(radius: .constant(5.0))
        //simulation.tick()
        measure {
            for _ in 0..<120 {
                simulation.tick()
            }
        }
    }

    func test_generic_pack_3d() {

        let data = getData()

        let simulation = Simulation(
            nodeCount: data.nodes.count,
            links: getLinks(),
            forceField: MyForceField3D()
        )

        // let wrapped = Simulation2D(
        //     nodeIds: data.nodes.map { n in
        //         n.id
        //     }
        // )
        // .withLinkForce(
        //     data.links.map({ l in
        //         (l.source, l.target)
        //     })
        // )
        // .withManyBodyForce(strength: -30)
        // .withCenterForce(center: .zero)
        // .withCollideForce(radius: .constant(5.0))
        //simulation.tick()
        measure {
            for _ in 0..<120 {
                simulation.tick()
            }
        }
    }

}
