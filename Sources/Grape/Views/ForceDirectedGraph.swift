import ForceSimulation
import SwiftUI

@resultBuilder
public struct ForceFieldBuilder {
    public static func buildBlock(_ components: ForceDescriptor...) -> [ForceDescriptor] {
        return components
    }
}

public struct ForceDirectedGraph<NodeID: Hashable>: View {

    public typealias Proxy = ForceDirectedGraph2DProxy<NodeID>
    public typealias LayoutEngine = ForceDirectedGraph2DLayoutEngine

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

            for i in self.content.links {
                let source = self.nodeIdToIndexLookup[i.id.source]!
                let target = self.nodeIdToIndexLookup[i.id.target]!

                let sourceX = centerX + model.simulation.nodePositions[source].x
                let sourceY = centerY + model.simulation.nodePositions[source].y
                let targetX = centerX + model.simulation.nodePositions[target].x
                let targetY = centerY + model.simulation.nodePositions[target].y

                context.stroke(
                    Path { path in
                        path.move(to: CGPoint(x: sourceX, y: sourceY))
                        path.addLine(to: CGPoint(x: targetX, y: targetY))
                    },
                    with: .color(i.strokeColor),
                    style: StrokeStyle(lineWidth: i.strokeWidth)
                )
            }

            for i in model.simulation.nodePositions.indices {
                let node = content.nodes[i]
                let x = centerX + model.simulation.nodePositions[i].x - node.radius
                let y = centerY + model.simulation.nodePositions[i].y - node.radius

                let rect = CGRect(
                    origin: .init(x: x, y: y),
                    size: CGSize(
                        width: node.radius * 2, height: node.radius * 2
                    )
                )

                context.fill(
                    Path(ellipseIn: rect), with: .color(node.fill))
                if let strokeColor = node.strokeColor {
                    context.stroke(
                        Path(ellipseIn: rect), with: .color(Color(strokeColor)),
                        style: StrokeStyle(lineWidth: node.strokeWidth))
                }
            }
        }
    }


    @usableFromInline
    @State var model: LayoutEngine
    @usableFromInline let proxy: Proxy

    @usableFromInline let content: Content
    @usableFromInline let forceFieldDescriptor: [ForceDescriptor]

    @inlinable
    public init(
        proxy: Proxy,
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
                linkForceDescriptor.links = content.links.compactMap {
                    if let sourceId = lookup[$0.id.source],
                       let targetId = lookup[$0.id.target] {
                        return EdgeID(sourceId, targetId)
                    }
                    return nil
                    
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
        proxy.layoutEngine = model
        self.model = model
        self.proxy = proxy
    }

}
