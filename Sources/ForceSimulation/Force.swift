//
//  Force.swift
//
//
//  Created by li3zhen1 on 10/1/23.
//

import simd
import QuadTree

public struct EdgeID<VertexID>: Hashable where VertexID: Hashable{
    public let source: VertexID
    public let target: VertexID
    
    public init(_ source: VertexID, _ target: VertexID) {
        self.source = source
        self.target = target
    }
}


public struct SimulationNode<VID>: Identifiable where VID: Hashable {
    public internal(set) var id: VID
    public var position: Vector2f
    public var velocity: Vector2f
    public var fixation: Vector2f?
    
    public mutating func fix(_ position: Vector2f) {
        self.fixation = position
    }

    public mutating func unfix() {
        self.fixation = nil
    }

    public var isFixed: Bool {
        get {
            return self.fixation != nil
        }
    }

    public mutating func setVelocity(_ velocity: Vector2f) {
        self.velocity = velocity
    }

    public mutating func setPosition(_ position: Vector2f) {
        self.position = position
    }

    public mutating func setFixation(_ fixation: Vector2f) {
        self.fixation = fixation
    }

}

public struct SimulationEdge<VID>: Identifiable where VID: Hashable {
    public var id: EdgeID<VID> {
        get {
            return EdgeID(source, target)
        }
    }
    
    public var source: VID
    public var target: VID
}


public protocol Force {
    associatedtype N: Identifiable
    
    func apply(alpha: Float)
}




extension SimulationNode: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "\(self.id) [\(self.position.x), \(self.position.y)]"
    }
    
}
