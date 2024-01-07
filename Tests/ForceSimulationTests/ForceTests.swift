//
//  File.swift
//
//
//  Created by li3zhen1 on 10/4/23.
//

import XCTest
import simd

@testable import ForceSimulation

final class ForceTests: XCTestCase {

    private func _testForceMutatePositions(_ myForce: some Force2D) {

        let simulation = Simulation(
            nodeCount: 5,
            links: [(0, 1), (1, 2), (2, 3), (3, 4), (4, 0)].map { 
                EdgeID(source: $0.0, target: $0.1)
            },
            forceField: myForce
        )

        for _ in 0...10 {
            simulation.tick()
        }

        let position = simulation.kinetics.position.asArray()


        XCTAssertNotEqual(position, Array(repeating: .zero, count: 5))
    }


    func testLinkForceMutatesPosition() {
        _testForceMutatePositions(
            SealedForce2D {
                Kinetics2D.LinkForce(
                    stiffness: .weightedByDegree(k: { _, _ in 1.0 }),
                    originalLength: .constant(35)
                )
            }
        )
    }


    func testManyBodyForceMutatesPosition() {
        _testForceMutatePositions(
            SealedForce2D {
                Kinetics2D.LinkForce(
                    stiffness: .weightedByDegree(k: { _, _ in 1.0 }),
                    originalLength: .constant(35)
                )
                Kinetics2D.ManyBodyForce(strength: -300)
            }
        )
    }

}
