//
//  ContentView.swift
//  GrapeView
//
//  Created by li3zhen1 on 10/8/23.
//

import SwiftUI

import NDTree
import ForceSimulation
import CoreGraphics

let colors: [GraphicsContext.Shading] = [
    GraphicsContext.Shading.color(red: 17.0/255, green: 181.0/255, blue: 174.0/255),
    
    GraphicsContext.Shading.color(red: 64.0/255, green: 70.0/255, blue: 201.0/255),
    
    GraphicsContext.Shading.color(red: 246.0/255, green: 133.0/255, blue: 18.0/255),
    
    GraphicsContext.Shading.color(red: 222.0/255, green: 60.0/255, blue: 130.0/255),
    
    GraphicsContext.Shading.color(red: 17.0/255, green: 181.0/255, blue: 174.0/255),
    
    GraphicsContext.Shading.color(red: 114.0/255, green: 224.0/255, blue: 106.0/255),
    
    GraphicsContext.Shading.color(red: 22.0/255, green: 124.0/255, blue: 243.0/255),
    GraphicsContext.Shading.color(red: 115.0/255, green: 38.0/255, blue: 211.0/255),
    GraphicsContext.Shading.color(red: 232.0/255, green: 198.0/255, blue: 0.0/255),
    GraphicsContext.Shading.color(red: 203.0/255, green: 93.0/255, blue: 2.0/255),
    GraphicsContext.Shading.color(red: 0.0/255, green: 143.0/255, blue: 93.0/255),
    GraphicsContext.Shading.color(red: 188.0/255, green: 233.0/255, blue: 49.0/255),
]

struct MiserableNode: Identifiable {
    let id: Int
    let group: Int
    let name: String
}


typealias MiserableSimulation = Simulation<String,Vector2d>
typealias MiserableLinkForce = LinkForce<String,Vector2d>

struct ContentView: View {
    
    @State var points: [Vector2d] = []
    
    var sim: MiserableSimulation
    let data: Miserable
    var linkForce: MiserableLinkForce
    
    init() {
        self.data = getData(miserables)
        self.sim = Simulation(nodeIds: data.nodes.map {$0.id}, alphaDecay: 0.01)
        sim.createManyBodyForce(strength: -12)
        self.linkForce = sim.createLinkForce(
            data.links.map { l in (l.source, l.target) },
            stiffness: .weightedByDegree { _, _ in 1.0 },
            originalLength: .constant(35)
        )
        sim.createCenterForce(center: Vector2d(0, 0), strength: 0.4)
        sim.createCollideForce(radius: .constant(3))
        
    }
    
    var body: some View {
        NavigationStack {
            Canvas { context, sz in
                
                for l in self.data.links {
                    if let s = self.data.nodes.firstIndex(where: { $0.id == l.source}),
                       let t = self.data.nodes.firstIndex(where: { $0.id == l.target}) {
                        // draw a line from s to t
                        let x1 = CGFloat( 300.0 + self.sim.nodePositions[s].x )
                        let y1 = CGFloat( 200.0 - self.sim.nodePositions[s].y )
                        let x2 = CGFloat( 300.0 + self.sim.nodePositions[t].x )
                        let y2 = CGFloat( 200.0 - self.sim.nodePositions[t].y )
                        
                        context.stroke(Path { path in
                            path.move(to: CGPoint(x: x1, y: y1))
                            path.addLine(to: CGPoint(x: x2, y: y2))
                        }, with: .color(.gray.opacity(0.2)))
                    }
                }
                
                for i in self.points.indices {
                    
                    let x = 300.0 + points[i].x - 4.0
                    let y = 200.0 - points[i].y - 4.0
                    
                    let rect = CGRect(origin: .init(x: x, y: y), size: CGSize(width: 8.0, height: 8.0))
                    
                    context.fill(Path(ellipseIn: rect), with: colors[(self.data.nodes[i].group) % colors.count])
                    context.stroke(Path(ellipseIn: rect), with: .color(Color(nsColor: .windowBackgroundColor)), style: StrokeStyle(lineWidth: 1.5))
                    
                }
            }
            .onAppear {
                self.points = sim.nodePositions
            }
            .frame(width: 600, height: 400)
            .navigationTitle("Force Directed Graph Example")
            
        }.toolbar {
            
            Button(action: {
                Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { t in
                    sim.tick()
                    self.points = sim.nodePositions
                }
            }, label: {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Run")
                }.padding()
            })
        }
    }
}

#Preview {
    ContentView()
}
