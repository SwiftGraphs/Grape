//
//  ContentView.swift
//  ForceDirectedGraph3D
//
//  Created by li3zhen1 on 10/20/23.
//

import SwiftUI
import RealityKit
import RealityKitContent
import NDTree
import ForceSimulation


func buildSimulation() -> Simulation3D<String> {
    let data = getData(miserables)
    
    let sim = Simulation3D(nodeIds: data.nodes.map { $0.id } )
    
    sim.createCenterForce(center: .zero)
    sim.createManyBodyForce(strength: -1)
    sim.createLinkForce(data.links.map { ($0.source, $0.target) }, stiffness: .constant(0.5))
    
    for i in 0..<720 {
        sim.tick()
    }
    return sim
}


func getLinkIndices() -> [(Int, Int)] {
    let data = getData(miserables)
    
    let linkIds = data.links.map { l in
        (data.nodes.firstIndex{l.source==$0.id}!, data.nodes.firstIndex{l.target==$0.id}!) }
    return linkIds
}

let scaleRatio: Float = 0.0027


let materialColors: [UIColor] = [
    UIColor(red: 17.0/255, green: 181.0/255, blue: 174.0/255, alpha: 1.0),
    UIColor(red: 64.0/255, green: 70.0/255, blue: 201.0/255, alpha: 1.0),
    UIColor(red: 246.0/255, green: 133.0/255, blue: 18.0/255, alpha: 1.0),
    UIColor(red: 222.0/255, green: 60.0/255, blue: 130.0/255, alpha: 1.0),
    UIColor(red: 17.0/255, green: 181.0/255, blue: 174.0/255, alpha: 1.0),
    UIColor(red: 114.0/255, green: 224.0/255, blue: 106.0/255, alpha: 1.0),
    UIColor(red: 22.0/255, green: 124.0/255, blue: 243.0/255, alpha: 1.0),
    UIColor(red: 115.0/255, green: 38.0/255, blue: 211.0/255, alpha: 1.0),
    UIColor(red: 232.0/255, green: 198.0/255, blue: 0.0/255, alpha: 1.0),
    UIColor(red: 203.0/255, green: 93.0/255, blue: 2.0/255, alpha: 1.0),
    UIColor(red: 0.0/255, green: 143.0/255, blue: 93.0/255, alpha: 1.0),
    UIColor(red: 188.0/255, green: 233.0/255, blue: 49.0/255, alpha: 1.0),
]


struct ContentView: View {
    var body: some View {
        
        VStack {
            RealityView { content in
                
                var material = PhysicallyBasedMaterial()
                material.baseColor = PhysicallyBasedMaterial.BaseColor(tint: UIColor(white: 1.0, alpha: 0.2))
                material.roughness = PhysicallyBasedMaterial.Roughness(floatLiteral: 0.8)
                material.metallic = PhysicallyBasedMaterial.Metallic(floatLiteral: 0.2)
                
                
                
                
                let nodeMaterials = materialColors.map { c in
                    var material = PhysicallyBasedMaterial()
                    material.baseColor = PhysicallyBasedMaterial.BaseColor(tint: c)
                    material.roughness = PhysicallyBasedMaterial.Roughness(floatLiteral: 1.0)
                    material.metallic = PhysicallyBasedMaterial.Metallic(floatLiteral: 0.01)
                    
                    material.emissiveColor = PhysicallyBasedMaterial.EmissiveColor(color: c)
                    material.emissiveIntensity = 0.4
                    return material
                }
                
                let sim = buildSimulation()
                
                let positions = sim.nodePositions.map { pos in  simd_float3(
                    Float(pos[1]) * scaleRatio,
                    -Float(pos[0]) * scaleRatio,
                    Float(pos[2]) * scaleRatio + 0.25
                )}
                
                
                for i in positions.indices {
                    let gid = getData(miserables).nodes[i].group
                    
                    let sphere = MeshResource.generateSphere(radius: 0.005)
                    
                    let sphereEntity = ModelEntity(mesh: sphere, materials: [
                        nodeMaterials[gid%nodeMaterials.count]
                    ])
                    
                    sphereEntity.position = positions[i]
                    
                    content.add(sphereEntity)
                }
                
                
                
                
                
                let linkIds = getLinkIndices()
                
                for (f, t) in linkIds {
                    content.add(
                        createCylinder(
                            from: positions[f],
                            to: positions[t],
                            material: material
                        )
                    )
                }
                
                
                
                
                
            }
            .frame(depth: 10.0)
            
            
        }.ornament(attachmentAnchor: .scene(alignment: .bottom)) {
            Button {
                
            } label: {
                Text("Force Directed Graph Example for visionOS")
            }
        }
            
    }
    
    
    private func createCylinder(
        from fromPosition: simd_float3,
        to toPosition: simd_float3,
        material: PhysicallyBasedMaterial
    ) -> ModelEntity {

        
        
//        let fromPosition: simd_float3 = [Float(_fromPosition[0]), Float(_fromPosition[1]), Float(_fromPosition[2])]
//        let toPosition: simd_float3 = [Float(_toPosition[0]), Float(_toPosition[1]), Float(_toPosition[2])]
        

        
        let cylinderVector = toPosition - fromPosition

        // calculate the height of the cylinder as the distance between the two points
        let height = simd_length(cylinderVector)
        let direction = simd_normalize(cylinderVector)

        // calculate the midpoint position
        let midpoint = SIMD3<Float>((fromPosition.x + toPosition.x) / 2,
                                    (fromPosition.y + toPosition.y) / 2,
                                    (fromPosition.z + toPosition.z) / 2)

        // create the cylinder
        let cylinder = MeshResource.generateCylinder(height: height, radius: 0.0005)
        let cylinderEntity = ModelEntity(mesh: cylinder, materials: [material])

        // The default cylinder is aligned along the y-axis. Assuming the 'direction' is not parallel to the y-axis,
        // calculate the quaternion to rotate from the y-axis to the desired direction.
        let yAxis = SIMD3<Float>(0, 1, 0) // default cylinder orientation
        let dotProduct = simd_dot(yAxis, direction)
        let crossProduct = simd_cross(yAxis, direction)

        // Using the dot product (cosine of angle) and the cross product (axis of rotation)
        // to create a quaternion representing the rotation
        let quaternion = simd_quatf(ix: crossProduct.x, iy: crossProduct.y, iz: crossProduct.z, r: 1 + dotProduct)

        // Normalize the quaternion to ensure valid rotation
        let rotation = simd_normalize(quaternion)

        // Apply the transformations
        cylinderEntity.transform = Transform(scale: SIMD3<Float>(1, 1, 1),
                                             rotation: rotation,
                                             translation: midpoint)

        return cylinderEntity
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
