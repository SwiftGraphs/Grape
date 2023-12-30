import SwiftUI
import ForceSimulation

extension ForceDirectedGraph: View {
    
    @inlinable
    public var body: some View {
        HStack {
            debugView
            canvas
        }
        .onChange(
            of: self._graphRenderingContextShadow,
            initial: false  // Don't trigger on initial value, keep `changeMessage` as "N/A"
        ) { _, newValue in
            self.model.revive(for: newValue, with: .init(self._forceDescriptors))
        }
        .onChange(of: self.isRunning, initial: false) { oldValue, newValue in
            guard oldValue != newValue else { return }
            if newValue {
                self.model.start()
            } else {
                self.model.stop()
            }
        }
    }
    
    @ViewBuilder
    @inlinable
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
    @inlinable
    @MainActor
    var canvas: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        
        Canvas(rendersAsynchronously: true) { context, size in 
            self.model.render(&context, size)
        }.border(.red, width: 1)
    }
}

extension ForceDirectedGraph: Equatable {
    @inlinable
    public static func == (lhs: ForceDirectedGraph<NodeID>, rhs: ForceDirectedGraph<NodeID>) -> Bool
    {
        return lhs._graphRenderingContextShadow == rhs._graphRenderingContextShadow
//        && lhs._forceDescriptors == rhs._forceDescriptors
    }
}
