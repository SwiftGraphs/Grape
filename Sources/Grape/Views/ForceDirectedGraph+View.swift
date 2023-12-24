import SwiftUI

extension ForceDirectedGraph: View {
    public var body: some View {
        #if DEBUG
        let _ = Self._printChanges()
        let _ = print("Evaluating View: \(self.graphContext.nodes.count)")
        #endif
        VStack {
            Button {
                self.clickCount += 1
            } label: {
                Text("Click \(clickCount)")
            }
            ForEach(self.graphContext.nodes, id: \.id) { node in
                Text("\(node.debugDescription)")
            }
        }.onChange(of: self.graphContext, initial: true) { oldValue, newValue in
            print("Graph context changed from \(oldValue.nodes.count) to \(newValue.nodes.count)")
        }
    }
}
