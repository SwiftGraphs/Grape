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
        
        let manybodyForce = sim.createManyBodyForce(name: "manybody1", strength: -30)
        
        let linkForce = sim.createLinkForce(name: "link1", links: data.links.map({ l in
            (l.source, l.target)
        }))
        
        let centerForce = sim.createCenterForce(name: "center1", center: .zero)
        

//        sim.tick()
//        measure {
            for _ in 0..<60{
                sim.tick()
            }
//        }
        sim.tick()
        print(sim.simulationNodes)
        
        
    }
    
    
}
