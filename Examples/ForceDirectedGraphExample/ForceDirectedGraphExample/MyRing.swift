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

        ForceDirectedGraph(isRunning: $isRunning) {
            
            for i in 0..<20 {
                NodeMark(id: 3 * i + 0, fill: .green)
                NodeMark(id: 3 * i + 1, fill: .blue)
                NodeMark(id: 3 * i + 2, fill: .yellow)

                LinkMark(from: 3 * i + 0, to: 3 * i + 1)
                LinkMark(from: 3 * i + 1, to: 3 * i + 2)

                for j in 0..<3 {
                    LinkMark(from: 3 * i + j, to: 3 * ((i + 1) % 20) + j)
                }
            }

        } forceField: {
            LinkForce(
                originalLength: .constant(20.0),
                stiffness: .weightedByDegree(k: { _, _ in 3.0})
            )
            CenterForce()
            ManyBodyForce(strength: -15)
        }
        

    }
}
