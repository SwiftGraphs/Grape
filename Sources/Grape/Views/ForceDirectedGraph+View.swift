import SwiftUI

extension ForceDirectedGraph: View {
    public var body: some View {
        #if DEBUG
        let _ = Self._printChanges()
        let _ = print("Evaluating View: \(self.model.graphRenderingContext.nodes.count)")
        #endif
        VStack {
            Text("Elapsed Time: \(model.currentFrame.rawValue)")
            Button {
                self.clickCount += 1
            } label: {
                Text("Click \(clickCount)")
                Text(self.model.changeMessage)
            }
            ForEach(self.model.graphRenderingContext.nodes, id: \.id) { node in
                Text("\(node.debugDescription)")
            }
        }
        .onChange(
            of: self._graphRenderingContextShadow, 
            initial: false // Don't trigger on initial value, keep `changeMessage` as "N/A"
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
}
