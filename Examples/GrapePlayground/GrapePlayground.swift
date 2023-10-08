//
//  File.swift
//  
//
//  Created by li3zhen1 on 10/4/23.
//


import SwiftUI
import ForceSimulation
import QuadTree

struct NamedNode: Identifiable {
    let name: String
    let id: Int
    
    static var count = 0
    static func make(_ name: String) -> NamedNode {
        defer { count += 1 }
        return NamedNode(name: name, id: count)
    }
}


let nodes_: [NamedNode] = [
    .make("Alice"),
    .make("Bob"),
    .make("Carol"),
    .make("David")
]

let pos = [(-10,-10), (-10,10), (10,-10), (10, 10)]


struct ContentView2: View {
    
    let sim = {
        let s = Simulation(nodes: nodes_) { n, i in
            n.position = Vector2f(x: Float(pos[i].0), y: Float(pos[i].1))
        }
        let f = s.createManyBodyForce(name: "f1", strength: -10.0)
        return s
    }()
    
    @State var simNodes: [SimulationNode<Int>] = []
    
    init() {
        
    }
    
    
    var body: some View {
        VStack {
            Canvas { ctx, cgSize in
                
                simNodes.forEach { n in
                    print(n.position)
                    let rect = CGRect(
                        x: CGFloat(n.position.x*5.0 + 150.0),
                        y: CGFloat(n.position.y*5.0 + 150.0),
                        width: 10,
                        height: 10)
                    let circle = Circle().path(in: rect)
                    ctx.fill(circle, with: .color(.red))
                }
                
            }.frame(width: 300, height: 300)
                .border(.blue)
                .onAppear(perform: {
                    simNodes = sim.simulationNodes
                })
            Button {
                Timer.scheduledTimer(withTimeInterval: 1/120, repeats: true) { t in
                    
                    sim.tick()
                    simNodes = sim.simulationNodes
                    
                }
            } label: {
                Text("Tick")
            }
        }
        .padding()
    }
}

struct ContentView: View {
    var body: some View {
        Text("Hello")
    }
}

//#Preview {
//    ContentView2()
//}



