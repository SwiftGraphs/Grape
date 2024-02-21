import ForceSimulation
import SwiftUI

extension ForceDirectedGraph: View {
    
    @inlinable
    public var body: some View {
        // HStack {
        //     #if DEBUG
        //         debugView
        //     #endif
        //     canvas
        // }
        canvas
            .onChange(
                of: self._graphRenderingContextShadow,
                initial: false  // Don't trigger on initial value, keep `changeMessage` as "N/A"
            ) { _, newValue in
                self.model.revive(
                    for: newValue,
                    with: .init(self._forceDescriptors),
                    alpha: self.model.simulationContext.storage.kinetics.alpha
                )
            }
            .onAppear {
                self.model.trackStateMixin()
            }
    }
    
    // #if DEBUG
    
    @ViewBuilder
    @inlinable
    var debugView: some View {
        VStack(alignment: .leading, spacing: 8.0) {
            Text("Elapsed Time: \(model.currentFrame)")
            Divider()
            Text(self.model.changeMessage)
            Divider()
            Button {
                // self.clickCount += 1
            } label: {
                Text("Click")
            }
            
            ScrollView {
                ForEach(self.model.graphRenderingContext.nodes, id: \.id) { node in
                    Text("\(node.debugDescription)")
                }
            }.frame(maxWidth: .infinity)
            
        }
        .frame(width: 200.0)
    }
    
    // #endif
    
    @inlinable
    @MainActor
    @ViewBuilder
    var canvas: some View {
        // #if DEBUG
        //     let _ = Self._printChanges()
        // #endif
        
        Canvas { context, size in
            let _ = model.currentFrame
            self.model.render(&context, size)
        }
#if !os(tvOS)
        .gesture(
            DragGesture(
                minimumDistance: Self.minimumDragDistance,
                coordinateSpace: .local
            )
            .onChanged(onDragChange)
            .onEnded(onDragEnd)
        )
        .onTapGesture(count: 1, perform: onTapGesture)
#endif

#if os(iOS) || os(macOS)
        .gesture(
            MagnifyGesture(minimumScaleDelta: Self.minimumScaleDelta)
                .onChanged(onMagnifyChange)
                .onEnded(onMagnifyEnd)
        )
#endif
    }
}

extension ForceDirectedGraph: Equatable {
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool
    {
        return lhs._graphRenderingContextShadow == rhs._graphRenderingContextShadow
        //        && lhs._forceDescriptors == rhs._forceDescriptors
    }
}
