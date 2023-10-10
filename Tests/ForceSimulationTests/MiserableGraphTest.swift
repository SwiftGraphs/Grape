//
//  File.swift
//
//
//  Created by li3zhen1 on 10/4/23.
//

import XCTest
import QuadTree
@testable import ForceSimulation


final class MiserableGraphTest: XCTestCase {
    
    func test() {
        let data = getData()
        
        let sim = Simulation(nodes: data.nodes)
        
        let manybodyForce = sim.createManyBodyForce(strength: -30)
        
        let linkForce = sim.createLinkForce(links: data.links.map({ l in
            (l.source, l.target)
        }))
        
        let centerForce = sim.createCenterForce(center: .zero)
        let collideForce = sim.createCollideForce(radius: .constant(5))

//        sim.tick()
        measure {
            for _ in 0..<120{
                sim.tick()
            }
        }
        sim.tick()
//        print(sim.simulationNodes)
        
        
    }
    
    
}
