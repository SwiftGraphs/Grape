import SwiftUI

extension ForceDirectedGraph: View {

    public var body: some View {
        #if DEBUG
            let _ = Self._printChanges()
        #endif
        HStack {
            debugView
            canvas
        }
        .onChange(
            of: self._graphRenderingContextShadow,
            initial: false  // Don't trigger on initial value, keep `changeMessage` as "N/A"
        ) { _, newValue in
            self.model.revive(with: newValue)
        }
        .onChange(of: self.isRunning, initial: false) { oldValue, newValue in
            if newValue {
                self.model.start()
            } else {
                self.model.stop()
            }
        }
    }

    @ViewBuilder
    @usableFromInline
    var debugView: some View {
        VStack(alignment: .leading, spacing: 8.0) {
            Text("Elapsed Time: \(model.currentFrame.rawValue)")
            Divider()
            Text(self.model.changeMessage)
            Divider()
            Button {
                self.clickCount += 1
            } label: {
                Text("Click \(clickCount)")
            }
            ScrollView {
                ForEach(self.model.graphRenderingContext.nodes, id: \.id) { node in
                    Text("\(node.debugDescription)")
                }
            }.frame(maxWidth: .infinity)
        }
        .frame(width: 200.0)
    }

    @ViewBuilder
    @usableFromInline
    var canvas: some View {
        Canvas { context, size in
            self.model.render(&context, size)
        }
        .border(.red, width: 1)
    }
}

extension ForceDirectedGraph: Equatable {
    public static func == (lhs: ForceDirectedGraph<NodeID>, rhs: ForceDirectedGraph<NodeID>) -> Bool
    {
        return lhs._graphRenderingContextShadow == rhs._graphRenderingContextShadow
    }
}
