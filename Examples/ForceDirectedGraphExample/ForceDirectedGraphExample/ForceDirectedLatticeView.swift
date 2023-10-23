//
//  ForceDirectedLatticeView.swift
//  ForceDirectedGraphExample
//
//  Created by li3zhen1 on 10/18/23.
//

import CoreGraphics
import ForceSimulation
import simd
import SwiftUI

struct ForceDirectedLatticeView: View {
    @State var points: [simd_double2]? = nil

    private let sim: Simulation2D<Int>
    private let edgeIds: [(Int, Int)]
    private let nodeIds: [Int]
    private let canvasWidth: CGFloat = 800.0
    let width = 36

    init() {
        self.nodeIds = Array(0..<(width * width))

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

        //        self.edgeIds = Array(0..<width).flatMap { i in
        //            return Array(0..<width).flatMap{ j in [
        //                (width*i+j, width*i+j+1),
        //                (width*i+j, width*(i+1)+1)
        //            ] }
        //        }
        self.edgeIds = edge
        self.sim = Simulation2D(nodeIds: nodeIds)
        sim.createLinkForce(self.edgeIds, stiffness: .constant(1), originalLength: .constant(1))
        sim.createManyBodyForce(strength: -1)

    }

    var body: some View {
        Canvas { context, sz in
            guard let points else { return }
            for l in self.edgeIds {
                let s = points[l.0]
                let t = points[l.1]
                // draw a line from s to t
                let x1 = CGFloat(canvasWidth / 2 + s.x)
                let y1 = CGFloat(canvasWidth / 2 - s.y)
                let x2 = CGFloat(canvasWidth / 2 + t.x)
                let y2 = CGFloat(canvasWidth / 2 - t.y)

                context.stroke(
                    Path { path in
                        path.move(to: CGPoint(x: x1, y: y1))
                        path.addLine(to: CGPoint(x: x2, y: y2))
                    }, with: .color(.gray.opacity(0.7)))

            }

            for i in points.indices {

                let _i = Double(i / width) / Double(width)
                let _j = Double(i % width) / Double(width)
                let x = canvasWidth / 2 + points[i].x - 3.5
                let y = canvasWidth / 2 - points[i].y - 3.5

                let rect = CGRect(origin: .init(x: x, y: y), size: CGSize(width: 7.0, height: 7.0))

                context.fill(Path(ellipseIn: rect), with: .color(red: 1, green: _i, blue: _j))
                context.stroke(
                    Path(ellipseIn: rect), with: .color(red: 0.1568, green: 0.1568, blue: 0.1569),
                    style: StrokeStyle(lineWidth: 1.5))

            }
        }
        .onAppear {
            self.points = sim.nodePositions
        }
        .frame(width: canvasWidth, height: canvasWidth)
        .navigationTitle("Force Directed Lattice Example")
        .toolbar {
            Button(
                action: {
                    Timer.scheduledTimer(withTimeInterval: 1 / 60, repeats: true) { t in
                        self.sim.tick()
                        self.points = sim.nodePositions
                    }
                },
                label: {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Run")
                    }.padding()
                })
        }
    }

}

#Preview {
    ForceDirectedLatticeView()
}
