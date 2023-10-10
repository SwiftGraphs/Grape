//
//  ContentView.swift
//  GrapeView
//
//  Created by li3zhen1 on 10/8/23.
//

import SwiftUI

//import QuadTree
import ForceSimulation
import CoreGraphics

let colors: [GraphicsContext.Shading] = [
    GraphicsContext.Shading.color(red: 17.0/255, green: 181.0/255, blue: 174.0/255),
    
    GraphicsContext.Shading.color(red: 64.0/255, green: 70.0/255, blue: 201.0/255),
    
    GraphicsContext.Shading.color(red: 246.0/255, green: 133.0/255, blue: 18.0/255),
    
    GraphicsContext.Shading.color(red: 222.0/255, green: 60.0/255, blue: 130.0/255),
    
    GraphicsContext.Shading.color(red: 17.0/255, green: 181.0/255, blue: 174.0/255),
    
    GraphicsContext.Shading.color(red: 114.0/255, green: 224.0/255, blue: 106.0/255),
]

struct MiserableNode: Identifiable {
    let id: Int
    let group: Int
    let name: String
}


struct ContentView: View {
    
    @State var simulationNodes: [SimulationNode<String>] = []
    
    var sim: Simulation<Miserable.Node>
    let data: Miserable
    var linkForce: LinkForce<Miserable.Node>
    
    init() {
        self.data = getData(miserables)
        self.sim = Simulation(nodes: data.nodes, alphaDecay: 0.0005)
        
        sim.createManyBodyForce(strength: -30)
        
        self.linkForce = sim.createLinkForce(links: data.links.map({ l in (l.source, l.target) }), originalLength: .constant(35))
        
        sim.createCenterForce(center: .zero, strength: 0.1)
        
        sim.createCollideForce(radius: .constant(5))
        
    }
    
    var body: some View {
        NavigationStack {
            Canvas { context, sz in
                
                for l in self.data.links {
                    if let s = self.sim.getNode(l.source),
                       let t = self.sim.getNode(l.target) {
                        // draw a line from s to t
                        let x1 = CGFloat( 300.0 + s.position.x )
                        let y1 = CGFloat( 200.0 + s.position.y )
                        let x2 = CGFloat( 300.0 + t.position.x )
                        let y2 = CGFloat( 200.0 + t.position.y )
                        
                        
                        
                        context.stroke(Path { path in
                            path.move(to: CGPoint(x: x1, y: y1))
                            path.addLine(to: CGPoint(x: x2, y: y2))
                        }, with: .color(.gray.opacity(0.2)))
                    }
                }
                
                for (i, node) in self.simulationNodes.enumerated() {
                    
                    let x = 300 + node.position.x
                    let y = 200 + node.position.y
                    
                    let rect = CGRect(origin: .init(x: CGFloat(x-4.0), y: CGFloat(y-4.0)), size: CGSize(width: 8.0, height: 8.0))
                    
                    context.fill(Path(ellipseIn: rect), with: colors[self.data.nodes[i].group % colors.count])
                    
                    context.stroke(Path(ellipseIn: rect), with: .color(Color(nsColor: .windowBackgroundColor)), style: StrokeStyle(lineWidth: 1.5))
                    
                }
            }
            .onAppear {
                self.simulationNodes = sim.simulationNodes
//                self.sim.start(intervalPerTick: 1/120) { nodes in
//                    self.simulationNodes = nodes
//                }
            }
            .frame(width: 600, height: 400)
            .navigationTitle("Force Directed Graph Example")
            
        }.toolbar {
            
            Button(action: {
                self.sim.start(intervalPerTick: 1/120) { nodes in
                    self.simulationNodes = nodes
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
