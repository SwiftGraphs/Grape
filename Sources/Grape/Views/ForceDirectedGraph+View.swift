import SwiftUI

extension ForceDirectedGraph: View {
    public var body: some View {
        VStack {
            ForEach(self.graphContext.nodes, id: \.id) { node in
                Text("\(node.label ?? "")")
            }
        }
    }
}
