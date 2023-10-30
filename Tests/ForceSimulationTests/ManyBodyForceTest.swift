//
//  File.swift
//  
//
//  Created by li3zhen1 on 10/4/23.
//

import XCTest
// import ForceSimulation
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
        
    }
    
    
}
