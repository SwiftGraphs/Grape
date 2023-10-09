//
//  File.swift
//  
//
//  Created by li3zhen1 on 10/8/23.
//

import QuadTree


struct IdNode: Identifiable, HasMassLikeProperty {
    typealias ID = Int
    let id: Int
    
    static var idCounter = 0
    
    static public func new() -> Self {
        defer { idCounter += 1 }
        return Self(id: idCounter)
    }
    
    static public func reset() {
        idCounter = 0
    }
    
    var property: Float = 1
}

struct NamedNode: Identifiable, HasMassLikeProperty {
    typealias ID = Int
    let id: Int
    let name: String
    static var idCounter = 0
    
    static public func new(_ name: String) -> Self {
        defer { idCounter += 1 }
        return Self(id: idCounter, name: name)
    }
    
    static public func reset() {
        idCounter = 0
    }
    
    var property: Float = 1
}





extension QuadTreeNode2 {
    var jsStyleDescription: String {
        if let children {
            return "[\(children.northWest.jsStyleDescription), \(children.northEast.jsStyleDescription), \(children.southWest.jsStyleDescription), \(children.southEast.jsStyleDescription)]"
        }
        else {
            if nodes.count == 0 {
                return ""
            }
            else if nodes.count == 1{
                let first = nodes.first!
                return "{data: [\(first.value.x), \(first.value.y)]}"
            }
            else {
                
                
                var r1 = "", r2 = ""
                
                for (i, (_, p)) in nodes.enumerated() {
                    if i == nodes.count - 1 {
                        r1 += "{data: [\(p.x), \(p.y)]"
                    }
                    else {
                        r1 += "{data: [\(p.x), \(p.y)], next:"
                    }
                    r2 += "}"
                }
                
                return r1+r2
            }
        }
    }
}

extension QuadTree2 {
    var jsStyleDescription: String { return self.root.jsStyleDescription }
}
