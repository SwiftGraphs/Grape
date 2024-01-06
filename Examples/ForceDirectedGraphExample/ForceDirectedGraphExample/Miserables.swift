//
//  Miserables.swift
//  ForceDirectedGraphExample
//
//  Created by li3zhen1 on 11/5/23.
//

import Foundation
import Grape
import SwiftUI
import Charts


struct MiserableGraph: View {
    
    private let graphData = getData(miserables)
    
    @State private var isRunning = false
    @State private var opacity: Double = 0
    
    var body: some View {
        
        ForceDirectedGraph($isRunning) {
            
            ForEach(graphData.nodes) { node in
                NodeMark(id: node.id)
                    .symbol(.asterisk)
                    .symbolSize(radius: 9.0)
                    .stroke()
                    .foregroundStyle(
                        colors[node.group % colors.count]
                            .shadow(
                                .inner(
                                    color: colors[node.group % colors.count].opacity(0.3),
                                    radius: 3,
                                    x: 0,
                                    y: 1.5
                                )
                            )
                    )
                    .label(offset: [0.0, 12.0]) {
                        Text(node.id)
                            .font(.caption2)
                    }
            }
            
            ForEach(graphData.links) { l in
                LinkMark(from: l.source, to: l.target)
            }
            
        } force: {
            ManyBodyForce(strength: -20)
            LinkForce(
                originalLength: .constant(35.0),
                stiffness: .weightedByDegree(k: { _, _ in 1.0})
            )
            CenterForce()
        }
        
        .opacity(opacity)
        .animation(.easeInOut, value: opacity)
        .toolbar {
            Button {
                isRunning.toggle()
                if opacity < 1 {
                    opacity = 1
                }
            } label: {
                Image(systemName: isRunning ? "pause.fill" : "play.fill")
                Text(isRunning ? "Pause" : "Start")
            }
        }
    }
}
