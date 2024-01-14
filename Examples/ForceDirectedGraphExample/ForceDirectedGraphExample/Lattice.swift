//
//  Lattice.swift
//  ForceDirectedGraphExample
//
//  Created by li3zhen1 on 11/8/23.
//

import SwiftUI
import Grape


struct Lattice: View {
    
    let width = 20
    let edge: [(Int, Int)]
    @State var isRunning = false
    
    init() {
        var edge = [(Int, Int)]()
        for i in 0..<width {
            for j in 0..<width {
                if j != width - 1 {
                    edge.append((width * i + j, width * i + j + 1))
                }
                if i != width - 1 {
                    edge.append((width * i + j, width * (i + 1) + j))
                }
            }
        }
        self.edge = edge
    }
    
    @inlinable
    var body: some View {
        ForceDirectedGraph($isRunning) {
            
            Series(0..<(width*width)) { i in
                let _i = Double(i / width) / Double(width)
                let _j = Double(i % width) / Double(width)
                NodeMark(id: i, radius: 3.0)
                    .foregroundStyle(Color(red: 1, green: _i, blue: _j))
                    .stroke()
            }
            
            Series(edge) { from, to in
                LinkMark(from: from, to: to)
            }
            
        } force: {
            LinkForce(
                originalLength: .constant(0.8),
                stiffness: .weightedByDegree { _, _ in 1.0 }
            )
            ManyBodyForce(strength: -0.8)
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
