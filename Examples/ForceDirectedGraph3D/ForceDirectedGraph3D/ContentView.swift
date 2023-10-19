//
//  ContentView.swift
//  ForceDirectedGraph3D
//
//  Created by li3zhen1 on 10/18/23.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    
    
    var body: some View {
        RealityView { content in
            
        }
    }
    
    
    func generateNode() -> ModelComponent {
        let sphere = MeshResource.generateSphere(radius: 3)
        let component = ModelComponent(mesh: sphere, materials: [])
        
        return component
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
