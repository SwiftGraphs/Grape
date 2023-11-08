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
        ForceDirectedGraph(isRunning: $isRunning) {
            for i in graphData.nodes.indices {
                NodeMark(id: i, fill: colors[graphData.nodes[i].group % colors.count], radius: 3.0)
            }
            for l in graphData.links {
                let fromID = graphData.nodes.firstIndex { mn in
                    mn.id == l.source
                }!
                let toID = graphData.nodes.firstIndex { mn in
                    mn.id == l.target
                }!
                LinkMark(from: fromID, to: toID)
            }
        } forceField: {
            ManyBodyForce(strength: -20)
            LinkForce(
                originalLength: .constant(35.0),
                stiffness: .weightedByDegree(k: { _, _ in 1.0})
            )
            CenterForce()
            CollideForce()
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
