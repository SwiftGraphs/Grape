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
    @State private var inspectorPresented = false
    
    @State private var modelTransform: ViewportTransform = .identity.scale(by: 2.0)
    
    @ViewBuilder
    func getLabel(_ text: String) -> some View {
        Text(text)
            .font(.caption2)
            .padding(.vertical, 2.0)
            .padding(.horizontal, 6.0)
            .background(alignment: .center) {
                RoundedRectangle(cornerSize: .init(width: 12, height: 12))
                    .fill(.white)
                    .shadow(radius: 1.5, y: 1.0)
            } 
            .padding()
    }
    
    var body: some View {
        
        ForceDirectedGraph(
            $isRunning,
            $modelTransform
        ) {
            
            Series(graphData.nodes) { node in
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
                    .richLabel(node.id, offset: .zero) {
                        self.getLabel(node.id)
                    }
            }
            
            Series(graphData.links) { l in
                LinkMark(from: l.source, to: l.target)
            }
            
        } force: {
            ManyBodyForce(strength: -20)
            CenterForce()
            LinkForce(
                originalLength: .constant(35.0),
                stiffness: .weightedByDegree(k: { _, _ in 1.0})
            )
        }
        .onNodeTapped { node in
            inspectorPresented = true
        }
        .opacity(opacity)
        .animation(.easeInOut, value: opacity)
        
        .ignoresSafeArea()
        .toolbar {
            Text("\(modelTransform.scale)")
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
