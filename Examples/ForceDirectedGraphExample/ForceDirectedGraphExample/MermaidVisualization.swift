//
//  MermaidVisualization.swift
//  ForceDirectedGraphExample
//
//  Created by li3zhen1 on 1/6/24.
//

import SwiftUI
import RegexBuilder
import Grape
import simd

let mermaidLinkRegex = Regex {
    Capture(
        OneOrMore(.word)
    )
    OneOrMore(.whitespace)
    ChoiceOf {
        "-->"
        "<--"
        "—>"
        "<—"
        "->"
        "<-"
    }

    OneOrMore(.whitespace)
    Capture(
        OneOrMore(.word)
    )
}

func parseMermaid(
    _ text: String
) -> ([String], [(String, String)]) {
    let links = text.split(separator: "\n")
        .compactMap {
            if let results = $0.matches(of: mermaidLinkRegex).first {
                return (String(results.output.1), String(results.output.2))
            }
            return nil
        }
    let nodes = Array(Set(links.flatMap { [$0.0, $0.1] }))
    return (nodes, links)
}

func getInitialPosition(id: String, r: Double) -> SIMD2<Double> {
    if let firstLetter = id.first?.unicodeScalars.first {
        let deg = Double(firstLetter.value % 26) / 26 * 2 * .pi
        return [cos(deg) * r, sin(deg) * r]
    }
    return .zero
}

struct MermaidVisualization: View {
    
    @State private var text: String = """
    Alice --> Bob
    Bob --> Cindy
    Alice --> Dan
    Alice --> Cindy
    Tom --> Bob
    Tom --> Kate
    Kate --> Cindy
    
    """
    
    var parsedGraph: ([String], [(String, String)]) {
        parseMermaid(text)
    }
    
    var body: some View {
        ForceDirectedGraph {
            Repeated(parsedGraph.0) { node in
                NodeMark(id: node)
                    .symbol(RoundedRectangle(cornerSize: CGSize(width: 3, height: 3)))
                    .symbolSize(radius: 6)
                    .label(alignment: .bottom, offset: [0, 4]) {
                        Text(node)
                    }
            }
            Repeated(parsedGraph.1) { link in
                LinkMark(from: link.0, to: link.1)
            }
        } force: {
            ManyBodyForce()
            LinkForce(originalLength: .constant(70))
            CenterForce()
        } emittingNewNodesWithStates: { id in
            KineticState(position: getInitialPosition(id: id, r: 100))
        }
        .inspector(isPresented: .constant(true)) {
            VStack {
                Text("Edit the mermaid syntaxes to update the graph")
                    .font(.title)
                TextEditor(text: $text)
                    .fontDesign(.monospaced)
                    
            }.padding(.top)
        }

            
    }
}
