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
            ForEach(Array(0..<(width*width)), id:\.self) { i in
                
                let _i = Double(i / width) / Double(width)
                let _j = Double(i % width) / Double(width)
                
                NodeMark(id: i, radius: 3.0)
                    .foregroundStyle(Color(red: 1, green: _i, blue: _j))
                    .stroke()
            }
            for l in edge {
                
                LinkMark(from: l.0, to: l.1)
            }
        } force: {
            LinkForce(
                originalLength: .constant(0.8),
                stiffness: .weightedByDegree(k: { _, _ in 1})
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
