//
//  ContentView.swift
//  GrapeView
//
//  Created by li3zhen1 on 10/8/23.
//

import Grape


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

enum ExampleKind: Identifiable, Hashable {
    case ring
    case classicMiserable
    case lattice
    case mermaid
    
    var id: ExampleKind {
        self
    }
    
    static let list: [ExampleKind] = [.ring, .classicMiserable, .lattice, .mermaid]
}

extension ExampleKind {
    var description: String {
        switch self {
        case .ring:
            return "My Ring"
        case .mermaid:
            return "Mermaid visualization"
        case .classicMiserable:
            return "Les Misérables"
        case .lattice:
            return "Lattice"
        }
    }
}

struct ContentView: View {
    
    @State var selection: ExampleKind? = .ring
    
    var body: some View {
        
        NavigationSplitView {
            List(ExampleKind.list, selection: $selection) { kind in
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
            case .none:
                MermaidVisualization()
            }
        }
    }
}

#Preview {
    ContentView()
}


struct MyGraph: View {
    let myNodes = ["A", "B", "C"]
    let myLinks = [("A", "B"), ("B", "C")]

    var body: some View {
        ForceDirectedGraph {
            Series(myNodes) { id in
                NodeMark(id: id)
            }
            Series(myLinks) { from, to in
                LinkMark(from: from, to: to)
            }
        }
    }
}
