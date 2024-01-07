//
//  MermaidVisualization.swift
//  ForceDirectedGraphExample
//
//  Created by li3zhen1 on 1/6/24.
//

import SwiftUI
import RegexBuilder
import Grape

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

struct MermaidVisualization: View {
    
    @State private var text: String = """
    Alice --> Bob
    Bob --> Cindy
    Alice --> Dan
    Alice --> Cindy
    Tom --> Bob
    """
    
    var parsedGraph: ([String], [(String, String)]) {
        parseMermaid(text)
    }
    
    var body: some View {
        ForceDirectedGraph {
            Repeated(parsedGraph.0) { node in
                NodeMark(id: node)
                    .label(alignment: .bottom) {
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
