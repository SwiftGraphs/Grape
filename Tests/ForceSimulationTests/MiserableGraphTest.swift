//
//  File.swift
//
//
//  Created by li3zhen1 on 10/4/23.
//

// import ForceSimulation
import simd
import XCTest

@testable import ForceSimulation

final class MiserableGraphTest: XCTestCase {

    func test_Generic_2d() {
        let data = getData()

        let sim = SimulationKD<String, simd_double2>(
            nodeIds: data.nodes.map { n in
                n.id
            })

        let _ = sim.createLinkForce(
            data.links.map({ l in
                (l.source, l.target)
            }))
        let _ = sim.createManyBodyForce(strength: -30)

        let _ = sim.createCenterForce(center: .zero)
        let _ = sim.createCollideForce(radius: .constant(5))

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
            for _ in 0..<120 {
                sim.tick()
//                print(i)
            }
        }
        sim.tick()
        //        print(sim.simulationNodes)

    }
    

    func test_Inlined_2d() {
        let data = getData()

        let sim = Simulation2D<String>(
            nodeIds: data.nodes.map { n in
                n.id
            })

        let _ = sim.createLinkForce(
            data.links.map({ l in
                (l.source, l.target)
            }))
        let _ = sim.createManyBodyForce(strength: -30)

        let _ = sim.createCenterForce(center: .zero)
        let _ = sim.createCollideForce(radius: .constant(5))

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
            for _ in 0..<120 {
                sim.tick()
//                print(i)
            }
        }
        sim.tick()
        //        print(sim.simulationNodes)

    }
    
    
    func test3d() {
        let data = getData()

        let sim = Simulation3D(
            nodeIds: data.nodes.map { n in
                n.id
            })

        let _ = sim.createLinkForce(
            data.links.map({ l in
                (l.source, l.target)
            }))
        let _ = sim.createManyBodyForce(strength: -30)

        let _ = sim.createCenterForce(center: .zero)
        let _ = sim.createCollideForce(radius: .constant(5))

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
            for _ in 0..<120 {
                sim.tick()
            }
        }
        sim.tick()
        //        print(sim.simulationNodes)

    }
    
//    func test4d() {
//        let data = getData()
//
//        let sim = Simulation<String, Vector4d>(
//            nodeIds: data.nodes.map { n in
//                n.id
//            })
//
//        let linkForce = sim.createLinkForce(
//            data.links.map({ l in
//                (l.source, l.target)
//            }))
//        let manybodyForce = sim.createManyBodyForce(strength: -30)
//
//        let centerForce = sim.createCenterForce(center: .zero)
//        let collideForce = sim.createCollideForce(radius: .constant(5))
//        
//        measure {
//            for _ in 0..<120 {
//                sim.tick()
//            }
//        }
//        sim.tick()
//        //        print(sim.simulationNodes)
//
//    }

}
