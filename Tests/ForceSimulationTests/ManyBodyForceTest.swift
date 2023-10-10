//
//  File.swift
//  
//
//  Created by li3zhen1 on 10/4/23.
//

import XCTest
import QuadTree
@testable import ForceSimulation


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
        let nodes: [NamedNode] = [
            .make("Alice"),
            .make("Bob"),
            .make("Carol"),
            .make("David")
        ]
        
        let pos = [(-1,-1), (-1,1), (1,-1), (1, 1)]
        let sim = Simulation(nodes: nodes) { n, i in
            n.position = Vector2f(x: Float(pos[i].0), y: Float(pos[i].1))
        }
        
        
        let f = sim.createManyBodyForce(strength: 0.4)
        
        sim.tick()
        
        
        
        // sim.simulationNodes.forEach { n in
        //     print(n)
        // }
        
        
        // sim.tick()
        // sim.simulationNodes.forEach { n in
        //     print(n)
        // }
    }
    
    
}
