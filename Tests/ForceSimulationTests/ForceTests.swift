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

    func testManybodyForceMutatePositions() {

        let myForce = Kinetics2D.ManyBodyForce(strength: -300)


        let simulation = Simulation(
            nodeCount: 5,
            links: [],
            forceField: myForce
        )

        for i in 0...1000 {
            simulation.tick()
        }

        let position = simulation.kinetics.position.asArray()

        print(position)

        XCTAssertNotEqual(position, Array(repeating: .zero, count: 5))
    }

}
