//
//  File.swift
//  
//
//  Created by li3zhen1 on 10/1/23.
//

import Foundation


enum SimulationError: Error {
    case subscriptionToNonexistentNode
}


public class Simulation<N> where N: Identifiable/*, E: EdgeLike, E.VertexID == V*/ {
    
    public typealias NodeID = N.ID
    
    public var alpha: Float
    public var alphaMin: Float
    public var alphaDecay: Float
    public var alphaTarget: Float
    public var velocityDecay: Float
    

    public var forces: Dictionary<String, any Force> = [:]

    public var nodeIndexLookup: Dictionary<NodeID, Int> = [:] 
    public var simulationNodes: [SimulationNode<NodeID>]

    
    public init(nodes: [N] = [],
         alpha: Float = 1,
         alphaMin: Float = 1e-3,
         alphaDecay: Float? = nil,
         alphaTarget: Float = 0.0,
         velocityDecay: Float = 0.6,
         
         setInitialStatus: ( (inout SimulationNode<NodeID>, [SimulationNode<NodeID>].Index)->Void )? = nil
    ) {
        self.alpha = alpha
        self.alphaMin = alphaMin
        self.alphaDecay = alphaDecay ?? 1 - pow(alphaMin, 1.0/300.0)
        self.alphaTarget = alphaTarget
        
        self.velocityDecay = velocityDecay

        self.simulationNodes = nodes.map { n in
            SimulationNode(id: n.id, position: .zero, velocity: .zero)
        }
        self.nodeIndexLookup = Dictionary(uniqueKeysWithValues: simulationNodes.enumerated().map { ($0.1.id, $0.0) })

        if let setInitialStatus {
            for i in self.simulationNodes.indices {
                setInitialStatus(&simulationNodes[i], i)
            }
        }
        
    }
    
    
    private func step() {
        
    }
    
    public func tick(_ iterations: Int = 1) {
        for _ in 0..<iterations {
            alpha += (alphaTarget - alpha) * alphaDecay
            
            for (_, f) in forces {
                f.apply(alpha: alpha)
            }
            
            for i in simulationNodes.indices {
                if let fixation = simulationNodes[i].fixation {
                    simulationNodes[i].position = fixation
                }
                else {
                    simulationNodes[i].velocity *= velocityDecay
                    simulationNodes[i].position += simulationNodes[i].velocity
                }
            }
            
        }
    }

    @inlinable public func getNode(_ nodeId: NodeID) -> SimulationNode<NodeID>? {
        guard let index = nodeIndexLookup[nodeId] else { return nil }
        return simulationNodes[index]
    }

    @inlinable public func updateNode(nodeId: NodeID, update: (inout SimulationNode<NodeID>) -> Void) {
        guard let index = nodeIndexLookup[nodeId] else { return }
        update(&simulationNodes[index])
    } 

    @inlinable public func updateNode(index: [SimulationNode<NodeID>].Index, update: (inout SimulationNode<NodeID>) -> Void) {
        update(&simulationNodes[index])
    }
}


//func dxTest() {
//    let sim = Simulation<Int>()
//    let centerForce = sim.createCenterForce(name: "center", x: 0, y: 0, strength: 0.2)
//    let linkForce = sim.createLinkForce(name: "link", links: [(0, 2)])
//
//}


// extension Simulation {
    
//     subscript (dangerouslyGetById nodeId: NodeID) -> SimulationNode<NodeID> {
//         get {
//             // guard let index = nodeIndexLookup[nodeId] else { 
//             //     return nil
//             //     // throw SimulationError.subscriptionToNonexistentNode
//             // }
//             return simulationNodes[nodeIndexLookup[nodeId]]
//         }
//         set {
//             guard let newValue else { 
//                 return
//                 // throw SimulationError.subscriptionToNonexistentNode
//             }
//             guard let index = nodeIndexLookup[nodeId] else { 
//                 return
//                 // throw SimulationError.subscriptionToNonexistentNode
//             }
//             simulationNodes[index] = newValue
//         }
//     }
// }
