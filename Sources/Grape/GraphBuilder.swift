//
//  File.swift
//  
//
//  Created by li3zhen1 on 10/11/23.
//

import Foundation

internal protocol GraphMark {
    
}

struct NodeMark<NID>: Hashable where NID: Hashable {
    let id: NID
}

struct EdgeMarkID<NID>: Hashable where NID: Hashable {
    let source: NID
    let target: NID
}

struct EdgeMark<NID>: Identifiable where NID: Hashable{
    typealias AssociatedNodeMark = NodeMark<NID>
    let id: EdgeMarkID<NID>
}

struct Graph<NID> where NID: Hashable {
    let nodes: [NodeMark<NID>]
    let edges: [EdgeMark<NID>]
}


@resultBuilder
struct GraphBuilder<NID: Hashable> {
    static func buildBlock(_ parts: NodeMark<NID>...) -> Graph<NID> {
        
        return Graph(nodes: parts, edges: [])
    }
}
//
//func grape<NID>(@GraphBuilder marks: () -> GraphMark<NID>) -> Graph<NID> where GraphBuilder.NID == NID {
//    return content()
//}
//
//
//func test() {
//    var g = Graph(
//        NodeMark(id: 2)
//    )
//}


