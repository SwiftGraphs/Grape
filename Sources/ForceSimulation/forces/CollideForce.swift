//
//  CollideForce.swift
//  
//
//  Created by li3zhen1 on 10/1/23.
//

import QuadTree

enum CollideForceError: Error {
    case applyBeforeSimulationInitialized
}


public class CollideForce<N> where N : Identifiable {

    let radius: CollideRadius
    let iterationsPerTick: Int


    weak var simulation: Simulation<N>?

    internal init(
        radius: CollideRadius,
        iterationsPerTick: Int = 1
    ) {
        self.radius = radius
        self.iterationsPerTick = iterationsPerTick
    }
}


public extension CollideForce {
    enum CollideRadius{
        case constant(Float)
        case varied( (N.ID) -> Float )
        case polarCoordinatesOnRad( (Float, N.ID) -> Float )
    }
}


extension CollideForce: Force {
    public func apply(alpha: Float) {
        guard let sim = self.simulation else { return }

        for _ in 0..<iterationsPerTick {
            // guard let quad = try? QuadTree(nodes: sim.simulationNodes.map { ($0, $0.position) }) else { break }

        }
    }
}
