import SwiftUI

public struct ForceDirectedGraphContent<NodeID: Hashable> {

    var nodes: [NodeMark<NodeID>]
    var links: [LinkMark<NodeID>]

    init(@GraphContentBuilder<NodeID> builder: () -> PartialGraphMark<NodeID>) {
        let graphMark = builder()
        self.nodes = graphMark.nodes
        self.links = graphMark.links
    }

    init(nodes: [NodeMark<NodeID>], links: [LinkMark<NodeID>]) {
        self.nodes = nodes
        self.links = links
    }
}

struct TestGraphView: View {

    var controller = ForceDirectedGraph2DController<Int>()

    var body: some View {
        ForceDirectedGraph(controller: controller) {
            NodeMark(id: 2, fill: .accentColor, radius: 3.0, label: "Hello")
            NodeMark(id: 3)
            NodeMark(id: 4)
            3 <-- 4
            4 --> 2
            for i in 20..<40 {
                NodeMark(id: i)
                i --> i + 1
            }
            FullyConnected {
                NodeMark(id: 8)
                NodeMark(id: 9)
            }
            LinkMark(from: 3, to: 4)
            LinkMark(from: 2, to: 4)
        } forceField: {
            LinkForce()
        }
    }

    

}
