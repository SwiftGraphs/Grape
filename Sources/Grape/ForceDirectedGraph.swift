import ForceSimulation
import SwiftUI

@resultBuilder
public struct ForceFieldBuilder {
    public static func buildBlock(_ components: ForceDescriptor...) -> ForceField {
        return ForceField(forces: components)
    }
}

public struct ForceDirectedGraph<NodeID: Hashable>: View {
    public struct Content {
        public var nodes: [NodeMark<NodeID>]
        public var links: [LinkMark<NodeID>]

        public init(nodes: [NodeMark<NodeID>], links: [LinkMark<NodeID>]) {
            self.nodes = nodes
            self.links = links
        }
    }


    public var body: some View {
        EmptyView()
    }

    @usableFromInline let content: Content
    @usableFromInline let simulation: Simulation2D<NodeID>
    @usableFromInline let forceFieldDescriptor: ForceField

    @inlinable
    public init(
        @GraphContentBuilder<NodeID> _ buildGraphContent: () -> PartialGraphMark<NodeID>,
        @ForceFieldBuilder forceField buildForceField: () -> ForceField
    ) {
        let graphMark = buildGraphContent()
        self.content = Content(nodes: graphMark.nodes, links: graphMark.links)
        self.simulation = .init(nodeIds: graphMark.nodes.map(\.id))
        self.forceFieldDescriptor = buildForceField()
    }


    @inlinable
    func buildForceField() {
        for forceDescriptor in forceFieldDescriptor.forces {
            switch forceDescriptor {
            case let centerForce as CenterForce:
                simulation.addCenterForce(x: centerForce.x, y: centerForce.y, strength: centerForce.strength)
            case let manyBodyForce as ManyBodyForce:
                simulation.addManyBodyForce(strength: manyBodyForce.strength, theta: manyBodyForce.theta, distanceMin: manyBodyForce.distanceMin, distanceMax: manyBodyForce.distanceMax)
            case let linkForce as LinkForce:
                simulation.addLinkForce(strength: linkForce.strength, distance: linkForce.distance, iterations: linkForce.iterations)
            case let collideForce as CollideForce:
                simulation.addCollideForce(strength: collideForce.strength, radius: collideForce.radius, iterations: collideForce.iterations)
            case let directionForce as DirectionForce:
                simulation.addDirectionForce(strength: directionForce.strength, targetOnDirection: directionForce.targetOnDirection, direction: directionForce.direction)
            default:
                break
            }
        }
    }


}
