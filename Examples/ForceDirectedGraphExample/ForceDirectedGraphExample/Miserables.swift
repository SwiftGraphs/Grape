//
<<<<<<< HEAD
//  Miserables.swift
=======
//  ForceDirectedGraphSwiftUIExample.swift
>>>>>>> main
//  ForceDirectedGraphExample
//
//  Created by li3zhen1 on 11/5/23.
//

import Foundation
import Grape
import SwiftUI
<<<<<<< HEAD
import Charts


struct MiserableGraph: View {
    
    private let graphData = getData(miserables)
    
    @State private var isRunning = false
    @State private var opacity: Double = 0
    @State private var inspectorPresented = false
    
    var body: some View {
        
        ForceDirectedGraph($isRunning) {
            
            Repeated(graphData.nodes) { node in
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
            
            Repeated(graphData.links) { l in
                LinkMark(from: l.source, to: l.target)
            }
//            
=======
import ForceSimulation
import Charts


//struct MyForceField: ForceField {
//
//    typealias Vector = SIMD2<Double>
//
//    public var force = CompositedForce {
//        LinkForce(
//            originalLength: .constant(20.0),
//            stiffness: .weightedByDegree(k: { _, _ in 3.0})
//        )
//        CenterForce()
//        ManyBodyForce(strength: -15)
//    }
//}



struct MiserableGraph: View {
    
    @State var isRunning = false
    let graphData = getData(miserables)
    
    var body: some View {
        ForceDirectedGraph($isRunning) {
            
            for l in graphData.links {
                let fromID = graphData.nodes.firstIndex { mn in
                    mn.id == l.source
                }!
                let toID = graphData.nodes.firstIndex { mn in
                    mn.id == l.target
                }!
                LinkMark(from: fromID, to: toID)
            }
            ForEach(graphData.nodes.indices, id: \.self) { i in
                NodeMark(id: i)
                    .symbol(.asterisk)
                    .symbolSize(radius: 12.0)
                    .foregroundStyle(
                        colors[graphData.nodes[i].group % colors.count]
                            .shadow(.inner(color:colors[graphData.nodes[i].group % colors.count].opacity(0.3), radius: 3, x:0, y: 1.5))
                            .shadow(.drop(color:colors[graphData.nodes[i].group % colors.count].opacity(0.12), radius: 12, x:0, y: 8))
                    )
                    .stroke()
                    .label(offset: CGVector(dx: 0.0, dy: 12.0)) {
//                        if i.isMultiple(of: 5) {
                            Text(graphData.nodes[i].id)
                                .font(.title3)
//                        }
                    }
            }
>>>>>>> main
        } force: {
            ManyBodyForce(strength: -20)
            LinkForce(
                originalLength: .constant(35.0),
                stiffness: .weightedByDegree(k: { _, _ in 1.0})
            )
            CenterForce()
<<<<<<< HEAD
        }
        .onNodeTapped { node in
            inspectorPresented = true
        }
        .opacity(opacity)
        .animation(.easeInOut, value: opacity)
        .inspector(isPresented: $inspectorPresented) {
            Text("Hello")
        }

        .toolbar {
            Button {
                isRunning.toggle()
                if opacity < 1 {
                    opacity = 1
                }
=======
//            CollideForce()
        }
        .onNodeTapped {
            print($0)
        }
        .toolbar {
            Button {
                isRunning = !isRunning
>>>>>>> main
            } label: {
                Image(systemName: isRunning ? "pause.fill" : "play.fill")
                Text(isRunning ? "Pause" : "Start")
            }
        }
    }
}
