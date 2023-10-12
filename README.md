# Grape

![swift workflow](https://github.com/li3zhen1/Grape/actions/workflows/swift.yml/badge.svg)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fli3zhen1%2FGrape%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/li3zhen1/Grape)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fli3zhen1%2FGrape%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/li3zhen1/Grape)



A visualization-purposed force simulation library.


<img width="712" alt="ForceDirectedGraphLight" src="https://github.com/li3zhen1/Grape/assets/45376537/e0e8049d-25c2-4e5c-9623-6bf43ddddfa5">

### Examples

This is a force directed graph visualizing the data from [Force Directed Graph Component](https://observablehq.com/@d3/force-directed-graph-component), running at 120FPS on a SwiftUI Canvas. Take a closer look at the animation:

https://github.com/li3zhen1/Grape/assets/45376537/6a1c9510-8af6-4967-9c05-c304b2af59ee


### Features

|   | 2D simd | 3D simd | Metal |
| --- | --- | --- | --- |
| **NdTree** | ✅ | 🚧 |  |
| **Simulation** | ✅ | 🚧 | 🚧 |
| &emsp;LinkForce | ✅ |   |  |
| &emsp;ManyBodyForce | ✅ |  |  |
| &emsp;CenterForce | ✅ |  |  |
| &emsp;CollideForce | ✅ |  |  |
| &emsp;PositionForce | ✅ |  |  |
| &emsp;RadialForce | ✅ |  |  |
| **SwiftUI View** | 🚧 |  |  |


### Usage

```swift
import ForceSimulation

struct Node: Identifiable { ... }

let nodes: [Node] = ... 
let links: [(Node.ID, Node.ID)] = ... 

let sim = Simulation(nodes: nodes, alphaDecay: 0.0005)
sim.createManyBodyForce(strength: -30)
sim.createLinkForce(links: links, originalLength: .constant(35))
sim.createCenterForce(center: .zero, strength: 0.1)
sim.createCollideForce(radius: .constant(5))

```

See [Example](https://github.com/li3zhen1/Grape/tree/main/Examples/GrapeView) for more details.

### Performance

Grape uses simd to calculate position and velocity. Currently it takes ~0.13 seconds to iterate 120 times over the example graph. (77 vertices, 254 edges, with manybody, center, collide and link forces. Release build on a M1 Max)
