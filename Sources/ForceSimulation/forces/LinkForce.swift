//
//  LinkForce.swift
//
//
//  Created by li3zhen1 on 10/16/23.
//

import NDTree

enum LinkForceError: Error {
    case useBeforeSimulationInitialized
}


final public class LinkForce<NodeID, V>: ForceLike where NodeID: Hashable, V: VectorLike, V.Scalar == Double {
    
    
    
    ///
    public enum LinkStiffness {
        case constant(Double)
        case varied(   [EdgeID<NodeID>: Double], Double    )
    }
    var linkStiffness: LinkStiffness
    var calculatedStiffness: [Double] = []
    
    
    
    
    
    ///
    public typealias LengthScalar = V.Scalar
    public enum LinkLength {
        case constant(LengthScalar)
        case varied(   [EdgeID<NodeID>: Double], LengthScalar    )
    }
    var linkLength: LinkLength
    var calculatedLength: [LengthScalar] = []
    
    
    
    
    /// Bias
    var calculatedBias: [Double] = []
    
    
    
    
    
    /// Binding to simulation
    ///
    weak var simulation: Simulation<NodeID, V>?
    
    
    
    
    
    
    
    var iteractionsPerTick: UInt
    
    
    
    
    
    var links: [EdgeID<Int>]
    
    
    
    
    
    
    
    init(linkStiffness: LinkStiffness, calculatedStiffnes: [Double], linkLength: LinkLength, calculatedLength: [LengthScalar], calculatedBias: [Double], iteractionsPerTick: UInt, links: [EdgeID<Int>]) {
        self.linkStiffness = linkStiffness
        self.linkLength = linkLength
        self.calculatedLength = calculatedLength
        self.calculatedBias = calculatedBias
        self.iteractionsPerTick = iteractionsPerTick
        self.links = links
    }
    
    
    
    
    
    
    
    
    
    public func apply(alpha: Double) {
        guard let sim = self.simulation else { return }
        
        var position: V
        var l: Double
        
        for _ in 0..<iteractionsPerTick {
            for i in links.indices {
                let s = links[i].source
                let t = links[i].target
                
                let _source = sim.nodes[s]
                let _target = sim.nodes[t]
                
                let b = self.calculatedBias[i]
                
                position = (_target.position + _target.velocity - _source.position - _source.velocity).jiggled()
                
                l = position.length()
                
                l = (l - self.calculatedLength[i]) / l * alpha * self.calculatedStiffness[i]

                position *= l

                sim.nodes[s].velocity += position * b
                sim.nodes[t].velocity -= position * (1 - b)
                
            }
        }
    }
    
    
}




//extension LinkForce.LinkLength: PrecalculatableParameter {
//    public func calculated(for simulation: Simulation<NodeID, V>) -> [Double] {
//        switch self {
//        case .constant(let l):
//            return Array(repeating: l, count: simulation.nodes.count)
//        case .varied(let lenDict, let defaultLen):
//            return simulation.nodeIds.map { n in
//                return lenDict[n, default: defaultMass]
//            }
//        }
//    }
//    
//}
//
//
//extension LinkForce.LinkStiffness: PrecalculatableParameter {
//    public func calculated(for simulation: Simulation<NodeID, V>) -> [Double] {
//        switch self {
//        case .constant(let m):
//            return Array(repeating: m, count: simulation.nodes.count)
//        case .varied(let stiffnessDict, let defaultStiffness):
//            return simulation.nodeIds.map { n in
//                return stiffnessDict[n, default: defaultStiffness]
//            }
//        }
//    }
//}


