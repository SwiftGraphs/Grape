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



struct MyRing: View {
    
    @State var isRunning = false
    
    var body: some View {


        ForceDirectedGraph($isRunning) {
            Series(0..<20) { i in
                NodeMark(id: 3 * i + 0)
                    .symbol(.circle)
                    .symbolSize(radius:4.0)
                    .foregroundStyle(.green)
                NodeMark(id: 3 * i + 1)
                    .symbol(.pentagon)
                    .symbolSize(radius:5.0)
                    .foregroundStyle(.blue)
                NodeMark(id: 3 * i + 2)
                    .symbol(.circle)
                    .symbolSize(radius:6.0)
                    .foregroundStyle(.yellow)

                
                
                LinkMark(from: 3 * i + 0, to: 3 * i + 1)
                LinkMark(from: 3 * i + 1, to: 3 * i + 2)
                
                LinkMark(from: 3 * i + 0, to: 3 * ((i + 1) % 20) + 0)
                LinkMark(from: 3 * i + 1, to: 3 * ((i + 1) % 20) + 1)
                LinkMark(from: 3 * i + 2, to: 3 * ((i + 1) % 20) + 2)
                
            }
        } force: {
            ManyBodyForce(strength: -15)
            LinkForce(
                originalLength: .constant(20.0),
                stiffness: .weightedByDegree(k: { _, _ in 3.0})
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
