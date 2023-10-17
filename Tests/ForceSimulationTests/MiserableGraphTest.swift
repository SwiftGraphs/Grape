//
//  File.swift
//
//
//  Created by li3zhen1 on 10/4/23.
//

import XCTest
import NDTree
@testable import ForceSimulation


final class MiserableGraphTest: XCTestCase {
    
    func test() {
        let data = getData()
        
        let sim = Simulation<String, Vector2d>(nodeIds: data.nodes.map { n in
            n.id
        })
        

        let linkForce = sim.createLinkForce(data.links.map({ l in
            (l.source, l.target)
        }))
        let manybodyForce = sim.createManyBodyForce(strength: -30)

        let centerForce = sim.createCenterForce(center: .zero)
//        let collideForce = sim.createCollideForce(radius: .constant(5))
        
//        for _ in 0..<120{
//            sim.tick()
//        }
//        
////        sim.tick()
//        
//        for _ in 0..<120{
//            sim.tick()
//        }
        
       measure {
            for _ in 0..<120{
                sim.tick()
            }
       }
        sim.tick()
//        print(sim.simulationNodes)
        
        
    }
    
    
}
