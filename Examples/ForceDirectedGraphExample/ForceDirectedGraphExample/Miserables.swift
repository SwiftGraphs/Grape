//
//  ForceDirectedGraphSwiftUIExample.swift
//  ForceDirectedGraphExample
//
//  Created by li3zhen1 on 11/5/23.
//

import Foundation
import Grape
import SwiftUI
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
        } force: {
            ManyBodyForce(strength: -20)
            LinkForce(
                originalLength: .constant(35.0),
                stiffness: .weightedByDegree(k: { _, _ in 1.0})
            )
            CenterForce()
//            CollideForce()
        }
        .onNodeTapped {
            print($0)
        }
        .toolbar {
            Button {
                isRunning = !isRunning
            } label: {
                Image(systemName: isRunning ? "pause.fill" : "play.fill")
                Text(isRunning ? "Pause" : "Start")
            }
        }
    }
}
