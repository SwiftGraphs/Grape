//
//  File.swift
//  
//
//  Created by li3zhen1 on 11/7/23.
//

import Foundation

enum GraphDiffDescriptor<NodeID: Hashable> {
    
    case added([NodeID])
    
    case removed([NodeID])
    
    // re-resolve text?
    case modified([NodeID])
}


struct SequenceDiff<T: Hashable> {
    let intersection: [T]
    let `A-B`: [T]
    let `B-A`: [T]
}


extension SequenceDiff {
    @inlinable
    func calculate(a: [T], b: [T]) ->  {
        let aSet = Set(a)
        
        var intersection = [T]()
        var `A-B` = [T]()
        var `B-A` = [T]()
        
        `A∩B`.reserveCapacity(min(a.count, b.count))
        `A-B`.reserveCapacity(a.count)
        `B-A`.reserveCapacity(b.count)
        
        for i in updated {
            if aSet.contains(i) {
                intersection.append(
                    aSet.remove(i)
                )
                
            }
            else {
                `B-A`.append(i)
            }
        }
        `A-B` = Array(aSet)
    }
}
