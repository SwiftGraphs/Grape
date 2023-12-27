//
//  File.swift
//
//
//  Created by li3zhen1 on 12/26/23.
//

import ForceSimulation

public struct SealedForceDescriptor2D {
    public enum Entry {
        case center(Grape.CenterForce)
        case link(Grape.LinkForce)
        case manyBody(Grape.ManyBodyForce)
        case position(Grape.PositionForce)
        case collide(Grape.CollideForce)
        case radial(Grape.RadialForce)
    }

    @usableFromInline
    var storage: [Entry]

    @inlinable
    public init(_ entries: [Entry]) {
        self.storage = entries
    }
}

extension SealedForceDescriptor2D: ForceDescriptor {
    @inlinable
    public func createForce() -> ForceSimulation.SealedForce2D {
        let result = storage.map {
            switch $0 {
            case .center(let descriptor):
                return ForceSimulation.SealedForce2D.ForceEntry.center(
                    descriptor.createForce()
                )
            case .link(let descriptor):
                return ForceSimulation.SealedForce2D.ForceEntry.link(
                    descriptor.createForce()
                )
            case .manyBody(let descriptor):
                return ForceSimulation.SealedForce2D.ForceEntry.manyBody(
                    descriptor.createForce()
                )
            case .position(let descriptor):
                return ForceSimulation.SealedForce2D.ForceEntry.position(
                    descriptor.createForce()
                )
            case .collide(let descriptor):

                return ForceSimulation.SealedForce2D.ForceEntry.collide(
                    descriptor.createForce()
                )
            case .radial(let descriptor):
                return ForceSimulation.SealedForce2D.ForceEntry.radial(
                    descriptor.createForce()
                )
            }
        }
        return ForceSimulation.SealedForce2D(result)
    }
}

@resultBuilder
public struct SealForceDescriptor2DBuilder {
    public static func buildBlock() -> SealedForceDescriptor2D {
        return SealedForceDescriptor2D([])
    }
}
