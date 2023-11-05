import ForceSimulation
import SwiftUI

public protocol ForceDescriptor {}

public struct CenterForce: ForceDescriptor {
    public var x: Double
    public var y: Double
    public var strength: Double
}

public struct ManyBodyForce: ForceDescriptor {
    public var strength: Double
    public var theta: Double
    public var distanceMin: Double
    public var distanceMax: Double
}

public struct LinkForce: ForceDescriptor {
    public var strength: Double
    public var distance: Double
    public var iterations: Int
}

public struct CollideForce: ForceDescriptor {
    public var strength: Double
    public var radius: Double
    public var iterations: Int
}

public struct DirectionForce: ForceDescriptor {
    public enum Dimension: Hashable {
        case x
        case y
    }
    public var strength: Double
    public var targetOnDirection: Double
    public var direction: DirectionForce.Dimension
}

public struct ForceField {
    public let forces: [ForceDescriptor]
}

@resultBuilder
public struct ForceFieldBuilder {
    public static func buildBlock(_ components: ForceDescriptor...) -> ForceField {
        return ForceField(forces: components)
    }
}

public struct ForceDirectedGraph<NodeID: Hashable>: View {
    public struct Content {
        var nodes: [NodeMark<NodeID>]
        var links: [LinkMark<NodeID>]
    }

    public struct ForceSpec {

    }

    public var body: some View {
        EmptyView()
    }

    private let content: Content
    private let simulation: Simulation2D<NodeID>
    private let forceFieldDescriptor: ForceField

    public init(
        @GraphContentBuilder<NodeID> _ buildGraphContent: () -> PartialGraphMark<NodeID>,
        @ForceFieldBuilder _ buildForceField: () -> ForceField
    ) {
        let graphMark = buildGraphContent()
        self.content = Content(nodes: graphMark.nodes, links: graphMark.links)
        self.simulation = .init(nodeIds: graphMark.nodes.map(\.id))
        self.forceFieldDescriptor = buildForceField()
    }

}
