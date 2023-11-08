import ForceSimulation
import SwiftUI

// @resultBuilder
// public struct ForceFieldBuilder {
//     public static func buildBlock<Force>(_ components: ForceDescriptor<Force>...) -> [ForceDescriptor] {
//         return components
//     }
// }

public struct ForceDirectedGraph<NodeID: Hashable, ForceField: ForceProtocol>: View
where ForceField.Vector == SIMD2<Double> {

    public typealias Proxy = ForceDirectedGraph2DProxy<NodeID, ForceField>
    public typealias LayoutEngine = ForceDirectedGraph2DLayoutEngine

    public struct Content: GraphLike {
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
            self.proxy.lastRenderedSize = cgSize
            let centerX = cgSize.width / 2.0
            let centerY = cgSize.height / 2.0

            for i in self.content.links {
                let source = self.nodeIdToIndexLookup[i.id.source]!
                let target = self.nodeIdToIndexLookup[i.id.target]!

                let sourceX = centerX + model.simulation.kinetics.position[source].x
                let sourceY = centerY + model.simulation.kinetics.position[source].y
                let targetX = centerX + model.simulation.kinetics.position[target].x
                let targetY = centerY + model.simulation.kinetics.position[target].y

                context.stroke(
                    Path { path in
                        path.move(to: CGPoint(x: sourceX, y: sourceY))
                        path.addLine(to: CGPoint(x: targetX, y: targetY))
                    },
                    with: .color(i.strokeColor),
                    style: StrokeStyle(lineWidth: i.strokeWidth)
                )
            }

            for i in 0..<model.simulation.kinetics.position.header {
                let node = content.nodes[i]
                let x = centerX + model.simulation.kinetics.position[i].x - node.radius
                let y = centerY + model.simulation.kinetics.position[i].y - node.radius

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
        }.gesture(
            DragGesture(minimumDistance: 1.0)
                .onChanged { value in

                    let locationX = value.location.x - self.proxy.lastRenderedSize.width / 2
                    let locationY = value.location.y - self.proxy.lastRenderedSize.height / 2

                    guard let draggingNodeID = self.proxy.draggingNodeID else {

                        let nodeIndex = self.model.simulation.kinetics.position.firstIndex { node in
                            // Quad tree
                            let x = node.x
                            let y = node.y
                            let radius = 6.0
                            return locationX >= x - radius
                                && locationX <= x + radius
                                && locationY >= y - radius
                                && locationY <= y + radius
                        }

                        if let nodeIndex {
                            self.proxy.draggingNodeID = self.content.nodes[nodeIndex].id
                            //                            action(self.proxy.draggingNodeID!, value)
                        }
                        return
                    }
                    self.model.simulation.kinetics.fixation[
                        self.nodeIdToIndexLookup[draggingNodeID]!
                    ] = [locationX, locationY]
                    //                    action(draggingNodeID, value)

                }
                .onEnded { _ in
                    if self.proxy.draggingNodeID != nil {
                        self.model.simulation.kinetics.fixation[
                            self.nodeIdToIndexLookup[self.proxy.draggingNodeID!]!
                        ] = nil
                    }
                    self.proxy.draggingNodeID = nil

                }

        )
        .onTapGesture {

            let locationX = $0.x - self.proxy.lastRenderedSize.width / 2
            let locationY = $0.y - self.proxy.lastRenderedSize.height / 2

            let nodeIndex = self.model.simulation.kinetics.position.firstIndex { node in
                // Quad tree?
                let x = node.x
                let y = node.y
                let radius = 6.0
                return locationX >= x - radius
                    && locationX <= x + radius
                    && locationY >= y - radius
                    && locationY <= y + radius
            }
            if let nodeIndex {
                print(self.content.nodes[nodeIndex].id)
                //                action(
                //                    self.content.nodes[nodeIndex].id)
            }
        }

    }

    @usableFromInline
    @State var model: LayoutEngine<ForceField>
    @usableFromInline let proxy: Proxy

    @usableFromInline let content: Content
    // @usableFromInline let forceField: ForceField

    @inlinable
    public init(
        proxy: Proxy,
        @GraphContentBuilder<NodeID> _ buildGraphContent: () -> PartialGraphMark<NodeID>,
        @ForceBuilder<SIMD2<Double>> forceField buildForceField: () -> ForceField
    ) {
        let graphMark = buildGraphContent()
        self.content = Content(nodes: graphMark.nodes, links: graphMark.links)

        let lookup = Dictionary(
            uniqueKeysWithValues: graphMark.nodes.enumerated().map { ($1.id, $0) })

        let simulation = Simulation2D<ForceField>(
            nodeCount: graphMark.nodes.count,
            links: graphMark.links.map {
                .init(source: lookup[$0.id.source]!, target: lookup[$0.id.target]!)
            },
            forceField: buildForceField()
        )

        // for forceDescriptor in forceFieldDescriptor {
        //     if var linkForceDescriptor = forceDescriptor as? LinkForce {

        //         // inject links
        //         linkForceDescriptor.links = content.links.compactMap {
        //             if let sourceId = lookup[$0.id.source],
        //                let targetId = lookup[$0.id.target] {
        //                 return EdgeID(sourceId, targetId)
        //             }
        //             return nil

        //         }
        //         linkForceDescriptor.attachToSimulation(simulation)
        //     } else {
        //         forceDescriptor.attachToSimulation(simulation)
        //     }
        // }

        self.nodeIdToIndexLookup = lookup
        let _model = ForceDirectedGraph2DLayoutEngine(
            initialSimulation: simulation
        )
        proxy.layoutEngine = _model
        self.model = _model
        self.proxy = proxy
    }

}

extension ForceDirectedGraph {
    //    public func onDragGesture(
    //        minimumDistance: CGFloat = 10,
    //        coordinateSpace: CoordinateSpace = .local,
    //        _ action: @escaping (NodeID, DragGesture.Value) -> Void
    //    ) -> Self {
    //        self.gesture(
    //            DragGesture(minimumDistance: 1.0)
    //                .onChanged { value in
    //
    //                    let locationX = value.location.x - self.proxy.lastRenderedSize.width/2
    //                    let locationY = value.location.y - self.proxy.lastRenderedSize.height/2
    //
    //                    guard let draggingNodeID = self.proxy.draggingNodeID else {
    //
    //
    //                        let nodeIndex = self.model.simulation.nodePositions.firstIndex { node in
    //                            // Quad tree
    //                            let x = node.x
    //                            let y = node.y
    //                            let radius = 4.0
    //                            return locationX >= x - radius
    //                                && locationX <= x + radius
    //                                && locationY >= y - radius
    //                                && locationY <= y + radius
    //                        }
    //
    //                        if let nodeIndex {
    //                            self.proxy.draggingNodeID = self.content.nodes[nodeIndex].id
    //                            action(self.proxy.draggingNodeID!, value)
    //                        }
    //                        return
    //                    }
    //                    self.model.simulation.nodeFixations[
    //                        self.nodeIdToIndexLookup[draggingNodeID]!
    //                    ] = [locationX, locationY]
    //                    action(draggingNodeID, value)
    //
    //                }
    //                .onEnded { _ in
    //                    self.proxy.draggingNodeID = nil
    //                }
    //        )
    //
    //    }

}

extension ForceDirectedGraph {
    public func respondToGravity() -> Self {
        return self
    }

    public func respondToDragging(
        onDraggingStartedOnNode: ((NodeID) -> Bool)? = nil,
        onDraggingNode: ((NodeID) -> Bool)? = nil,
        onDraggingEndedOnNode: ((NodeID) -> Bool)? = nil
    ) -> Self {
        return self
    }

    public func respondToZoom(
        onZoomed: ((NodeID) -> Bool)? = nil
    ) -> Self {
        return self
    }
}
