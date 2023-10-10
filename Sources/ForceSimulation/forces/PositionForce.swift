//
//  PositionForce.swift
//
//
//  Created by li3zhen1 on 10/1/23.
//

final public class PositionForce<N>: Force where N: Identifiable {

    public enum Direction {
        case x
        case y
    }
    public enum TargetOnDirection {
        case constant(Float)
        case varied([N.ID: Float])
    }
    public enum Strength {
        case constant(Float)
        case varied([N.ID: Float])
    }
    public var strength: Strength
    public var direction: Direction
    public var calculatedStrength: [N.ID: Float] = [:]
    public var targetOnDirection: TargetOnDirection
    public var calculatedTargetOnDirection: [N.ID: Float] = [:]

    internal init(direction: Direction, targetOnDirection: TargetOnDirection, strength: Strength = .constant(1.0)) {
        self.strength = strength
        self.direction = direction
        self.targetOnDirection = targetOnDirection
    }

    weak var simulation: Simulation<N>? {
        didSet {
            guard let sim = self.simulation else { return }
            self.calculatedStrength = strength.calculated(sim.simulationNodes)
            self.calculatedTargetOnDirection = targetOnDirection.calculated(sim.simulationNodes)
        }
    }

    public func apply(alpha: Float) {
        guard let sim = self.simulation else { return }
        let vectorIndex = self.direction == .x ? 0 : 1
        for i in sim.simulationNodes.indices {
            let nodeId = sim.simulationNodes[i].id
            sim.simulationNodes[i].velocity += (
                self.calculatedTargetOnDirection[nodeId, default: 0.0] - sim.simulationNodes[i].position[vectorIndex]
            ) * self.calculatedStrength[nodeId, default: 0.0] * alpha
        }
    }
}

extension PositionForce.Strength {
    func calculated<SimNode>(_ nodes: [SimNode]) -> [N.ID: Float] where SimNode: Identifiable, SimNode.ID == N.ID {
        switch self {
        case .constant(let value):
            return nodes.reduce(into: [:]) { $0[$1.id] = value }
        case .varied(let dict):
            return dict
        }
    }
}

extension PositionForce.TargetOnDirection {
    func calculated<SimNode>(_ nodes: [SimNode]) -> [N.ID: Float] where SimNode: Identifiable, SimNode.ID == N.ID {
        switch self {
        case .constant(let value):
            return nodes.reduce(into: [:]) { $0[$1.id] = value }
        case .varied(let dict):
            return dict
        }
    }
}


public extension Simulation {
    func createPositionForce(
        direction: PositionForce<N>.Direction,
        targetOnDirection: PositionForce<N>.TargetOnDirection,
        strength: PositionForce<N>.Strength = .constant(1.0)
    ) -> PositionForce<N> {
        let force = PositionForce<N>(
            direction: direction,
            targetOnDirection: targetOnDirection,
            strength: strength
        )
        force.simulation = self
        self.forces.append(force)
        return force
    }
}