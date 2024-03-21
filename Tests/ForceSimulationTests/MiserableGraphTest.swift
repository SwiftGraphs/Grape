//
//  MiserableGraphTest.swift
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

struct MyForceField: ForceField2D {
    var force = CompositedForce<Vector, _, _> {
        Kinetics2D.ManyBodyForce(strength: -30)
        Kinetics2D.LinkForce(
            stiffness: .weightedByDegree(k: { _, _ in 1.0 }),
            originalLength: .constant(35)
        )
        Kinetics2D.CenterForce(center: .zero, strength: 1)
        Kinetics2D.CollideForce(radius: .constant(3))
    }
}

struct MySealedForce: ForceField2D {
    var force = SealedForce2D {
        Kinetics2D.ManyBodyForce(strength: -30)
        Kinetics2D.LinkForce(
            stiffness: .weightedByDegree(k: { _, _ in 1.0 }),
            originalLength: .constant(35)
        )
        Kinetics2D.CenterForce(center: .zero, strength: 1)
        Kinetics2D.CollideForce(radius: .constant(3))

    }
}

struct MyLatticeForce: ForceField2D {
    var force = SealedForce2D {
        Kinetics2D.LinkForce(
            stiffness: .weightedByDegree(k: { _, _ in 1.0 }),
            originalLength: .constant(1)
        )
        Kinetics2D.ManyBodyForce(strength: -1)
    }
}

struct MyForceField3D: ForceField3D {
    var force = CompositedForce<Vector, _, _> {
        Kinetics3D.ManyBodyForce(strength: -30)
        Kinetics3D.LinkForce(
            stiffness: .weightedByDegree(k: { _, _ in 1.0 }),
            originalLength: .constant(35)
        )
        Kinetics3D.CenterForce(center: .zero, strength: 1)
        Kinetics3D.CollideForce(radius: .constant(3))
    }
}

final class MiserableGraphTest: XCTestCase {

    #if DEBUG
        let iter = 3
    #else
        let iter = 120
    #endif
    func testLattice() {

        let myForce = SealedForce2D {
            Kinetics2D.ManyBodyForce(strength: -30)
            Kinetics2D.LinkForce(
                stiffness: .weightedByDegree(k: { _, _ in 1.0 }),
                originalLength: .constant(35)
            )
            Kinetics2D.CenterForce(center: .zero, strength: 1)
            Kinetics2D.CollideForce(radius: .constant(3))
        }

        let width = 20

        var edge = [(Int, Int)]()
        for i in 0..<width {
            for j in 0..<width {
                if j != width - 1 {
                    edge.append((width * i + j, width * i + j + 1))
                }
                if i != width - 1 {
                    edge.append((width * i + j, width * (i + 1) + j))
                }
            }
        }

        let simulation = Simulation(
            nodeCount: width * width,
            links: edge.map { EdgeID(source: $0.0, target: $0.1) },
            forceField: myForce
        )

        measure {
            for _ in 0..<iter {
                simulation.tick()
            }
        }
    }

    func testMiserable2d() {

        let data = getData()

        let simulation = Simulation(
            nodeCount: data.nodes.count,
            links: getLinks(),
            forceField: MySealedForce()
        )

        measure {
            for _ in 0..<iter {
                simulation.tick()
            }
        }
    }

    func testMiserable3d() {

        let data = getData()

        let simulation = Simulation(
            nodeCount: data.nodes.count,
            links: getLinks(),
            forceField: MyForceField3D()
        )

        measure {
            for _ in 0..<iter {
                simulation.tick()
            }
        }
    }

}
