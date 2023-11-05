//
//  ForceDirectedGraphSwiftUIExample.swift
//  ForceDirectedGraphExample
//
//  Created by li3zhen1 on 11/5/23.
//

import Foundation
import SwiftUI
import Grape


struct ForceDirectedGraphSwiftUIExample: View {
    let graphController = ForceDirectedGraph2DController<Int>()
    var body: some View {
        
        ForceDirectedGraph(controller: graphController) {
            
            NodeMark(id: 0, fill: .green)
            NodeMark(id: 1, fill: .blue)
            NodeMark(id: 2, fill: .yellow)
            
            for i in 0..<2 {
                LinkMark(from: i, to: i+1)
            }
            
        } forceField: {
            LinkForce()
            CenterForce()
            ManyBodyForce()
        }
        .onAppear {
            graphController.start()
        }

    }
}
