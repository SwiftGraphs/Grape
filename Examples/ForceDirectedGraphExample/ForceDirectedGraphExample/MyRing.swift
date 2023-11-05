//
//  ForceDirectedGraphSwiftUIExample.swift
//  ForceDirectedGraphExample
//
//  Created by li3zhen1 on 11/5/23.
//

import Foundation
import Grape
import SwiftUI

struct MyRing: View {
    let myProxy = ForceDirectedGraph<Int>.Proxy()
    var body: some View {

        ForceDirectedGraph(proxy: myProxy) {

            for i in 0..<20 {
                NodeMark(id: 3 * i + 0, fill: .green)
                NodeMark(id: 3 * i + 1, fill: .blue)
                NodeMark(id: 3 * i + 2, fill: .yellow)

                LinkMark(from: 3 * i + 0, to: 3 * i + 1)
                LinkMark(from: 3 * i + 1, to: 3 * i + 2)

                for j in 0..<3 {
                    LinkMark(from: 3 * i + j, to: 3 * ((i + 1) % 20) + j)
                }
            }

        } forceField: {
            LinkForce(originalLength: .constant(10.0))
            CenterForce()
            ManyBodyForce(strength: -5)
            DirectionForce(direction: .x, targetOnDirection: .constant(100), strength: .constant(0.01))
            DirectionForce(direction: .y, targetOnDirection: .constant(50), strength: .constant(0.02))
        }
        .onAppear {
            myProxy.start()
        }

    }
}
