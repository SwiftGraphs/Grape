import ForceSimulation
import SwiftUI

@resultBuilder
public struct ForceFieldBuilder {
    public static func buildBlock(_ components: ForceDescriptor...) -> [ForceDescriptor] {
        return components
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

    @usableFromInline
    var nodeIdToIndexLookup: [NodeID: Int]

    public var body: some View {
        Canvas { context, cgSize in
            let centerX = cgSize.width / 2.0
            let centerY = cgSize.height / 2.0

            for i in model.simulation.nodePositions.indices {
                let node = content.nodes[i]
                let x = centerX + model.simulation.nodePositions[i].x
                let y = centerY + model.simulation.nodePositions[i].y

                let rect = CGRect(origin: .init(x: x, y: y), size: CGSize(width: 8.0, height: 8.0))

                context.fill(
                    Path(ellipseIn: rect), with: .color(node.fill))
                context.stroke(
                    Path(ellipseIn: rect), with: .color(Color(nsColor: .windowBackgroundColor)),
                    style: StrokeStyle(lineWidth: 1.5))
            }
        }
    }

    // @inlinable
    func paintNodes(context: inout GraphicsContext, centerX: Double, centerY: Double) {

        for i in model.simulation.nodePositions.indices {
            let node = content.nodes[i]
            let x = centerX + model.simulation.nodePositions[i].x
            let y = centerY + model.simulation.nodePositions[i].y

            let rect = CGRect(origin: .init(x: x, y: y), size: CGSize(width: 8.0, height: 8.0))

            context.fill(
                Path(ellipseIn: rect), with: .color(node.fill))
            context.stroke(
                Path(ellipseIn: rect), with: .color(Color(nsColor: .windowBackgroundColor)),
                style: StrokeStyle(lineWidth: 1.5))
        }
    }

    @usableFromInline
    @State var model: ForceDirectedGraph2DLayoutEngine
    @usableFromInline var controller: ForceDirectedGraph2DController<NodeID>

    @usableFromInline let content: Content
    @usableFromInline let forceFieldDescriptor: [ForceDescriptor]

    @inlinable
    public init(
        controller: ForceDirectedGraph2DController<NodeID>,
        @GraphContentBuilder<NodeID> _ buildGraphContent: () -> PartialGraphMark<NodeID>,
        @ForceFieldBuilder forceField buildForceField: () -> [ForceDescriptor]
    ) {
        let graphMark = buildGraphContent()
        self.content = Content(nodes: graphMark.nodes, links: graphMark.links)

        let lookup = Dictionary(
            uniqueKeysWithValues: graphMark.nodes.enumerated().map { ($1.id, $0) })

        let simulation = Simulation2D<Int>(nodeIds: Array(graphMark.nodes.indices))
        self.forceFieldDescriptor = buildForceField()

        for forceDescriptor in forceFieldDescriptor {
            if var linkForceDescriptor = forceDescriptor as? LinkForce {
                // inject links
                linkForceDescriptor.links = content.links.map {
                    .init(
                        lookup[$0.id.source]!,
                        lookup[$0.id.target]!
                    )
                }
                linkForceDescriptor.attachToSimulation(simulation)
            } else {
                forceDescriptor.attachToSimulation(simulation)
            }
        }
        
        self.nodeIdToIndexLookup = lookup
        let model = ForceDirectedGraph2DLayoutEngine(
            initialSimulation: simulation
        )
        controller.layoutEngine = model
        self.model = model
        self.controller = controller
    }

}
