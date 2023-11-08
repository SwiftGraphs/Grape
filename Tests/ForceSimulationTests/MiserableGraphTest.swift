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

struct MyForceField: ForceField {

    typealias Vector = SIMD2<Double>

    var force: some ForceProtocol<Vector> = {
        let data = getData()

        return CompositedForce(
            CompositedForce(
                CompositedForce(
                    Kinetics<Vector>.LinkForce(
                        data.links.map { l in
                            .init(
                                source: data.nodes.firstIndex { n in n.id == l.source }!,
                                target: data.nodes.firstIndex { n in n.id == l.target }!
                            )
                        }, stiffness: .weightedByDegree(k: { _, _ in 1.0 })),
                    Kinetics<Vector>.ManyBodyForce(strength: -30)
                ),
                Kinetics<Vector>.CenterForce(center: 0, strength: 1)
            )
            ,
            Kinetics<Vector>.CollideForce(radius: .constant(5.0))
        )
    }()

}

final class MiserableGraphTest: XCTestCase {

    func test_generic_pack_2d() {

        let data = getData()

        let simulation = Simulation(
            nodeCount: data.nodes.count,
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
            for i in 0..<120 {
                simulation.tick()
            }
        }
    }

}
