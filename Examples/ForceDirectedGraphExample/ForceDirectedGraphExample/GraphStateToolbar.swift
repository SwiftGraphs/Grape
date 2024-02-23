//
//  GraphStateToolbar.swift
//  ForceDirectedGraphExample
//
//  Created by li3zhen1 on 2/22/24.
//

import Foundation
import SwiftUI
import Grape

struct GraphStateToggle: View {
    @Bindable var graphStates: ForceDirectedGraphState
    var body: some View {
        
        Group {
            Button {
                graphStates.modelTransform.scaling(by: 0.9)
            } label: {
                Image(systemName: "minus")
            }
            Text(String(format:"Scale: %.2f", graphStates.modelTransform.scale))
                .fontDesign(.monospaced)
            Button {
                graphStates.modelTransform.scaling(by: 1.1)
            } label: {
                Image(systemName: "plus")
            }
        }
        
        Button {
            graphStates.isRunning.toggle()
        } label: {
            Image(systemName: graphStates.isRunning ? "pause.fill" : "play.fill")
            Text(graphStates.isRunning ? "Pause" : "Start")
        }
    }
}
