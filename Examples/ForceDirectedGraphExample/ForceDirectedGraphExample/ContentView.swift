////
////  ContentView.swift
////  GrapeView
////
////  Created by li3zhen1 on 10/8/23.
////
//
//import SwiftUI
//import simd
//import ForceSimulation
//import CoreGraphics
//
//


//
//func getLinks() -> [EdgeID<Int>] {
//    let data = getData(miserables)
//    return data.links.map { l in
//        EdgeID(
//            data.nodes.firstIndex { n in n.id == l.source }!,
//            data.nodes.firstIndex { n in n.id == l.target }!
//        )
//    }
//}
//
//
//
import SwiftUI
let colors: [Color] = [
    .init(red: 17.0/255, green: 181.0/255, blue: 174.0/255),
    .init(red: 64.0/255, green: 70.0/255, blue: 201.0/255),
    .init(red: 246.0/255, green: 133.0/255, blue: 18.0/255),
    .init(red: 222.0/255, green: 60.0/255, blue: 130.0/255),
    .init(red: 17.0/255, green: 181.0/255, blue: 174.0/255),
    .init(red: 114.0/255, green: 224.0/255, blue: 106.0/255),
    .init(red: 22.0/255, green: 124.0/255, blue: 243.0/255),
    .init(red: 115.0/255, green: 38.0/255, blue: 211.0/255),
    .init(red: 232.0/255, green: 198.0/255, blue: 0.0/255),
    .init(red: 203.0/255, green: 93.0/255, blue: 2.0/255),
    .init(red: 0.0/255, green: 143.0/255, blue: 93.0/255),
    .init(red: 188.0/255, green: 233.0/255, blue: 49.0/255),
]
//
//struct MiserableNode: Identifiable {
//    let id: Int
//    let group: Int
//    let name: String
//}
//
//struct MyForceField: ForceField {
//    
//    typealias Vector = SIMD2<Double>
//    
//    public var force = CompositedForce {
//        Kinetics<Vector>.ManyBodyForce(strength: -12)
//        Kinetics<Vector>.LinkForce(
//            getLinks(),
//            stiffness: .weightedByDegree(k: { _, _ in 1.0 }),
//            originalLength: .constant(35)
//        )
//        Kinetics<Vector>.CenterForce(center: 0, strength: 0.4)
//        Kinetics<Vector>.CollideForce(radius: .constant(3))
//        
//    }
//}
//
//
import SwiftUI
enum ExampleKind {
    case ring
    case classicMiserable
    case lattice
    case mermaid
    
    static let list: [ExampleKind] = [.ring, .classicMiserable, .lattice, .mermaid]
}

extension ExampleKind {
    var description: String {
        switch self {
        case .ring:
            return "My Ring"
        case .classicMiserable:
            return "Miserables"
        case .lattice:
            return "Lattice"
        case .mermaid:
            return "Mermaid visualization"
        }
    }
}

struct ContentView: View {
    
    @State var selection: ExampleKind = .classicMiserable
    
    var body: some View {
        NavigationSplitView {
            List(ExampleKind.list, id:\.self, selection: $selection) { kind in
                Text(kind.description)
            }
        } detail: {
            switch selection {
            case .ring:
                MyRing()
            case .classicMiserable:
                MiserableGraph()
            case .lattice:
                Lattice()
            case .mermaid:
                MermaidVisualization()
            }
        }
    }
}

#Preview {
    ContentView()
}
