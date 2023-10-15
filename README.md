<p align="center">
  <img alt="grap-icon" src="https://github.com/li3zhen1/Grape/assets/45376537/e4eca3c1-e442-459e-be72-9620da5ac95e" height="96">
  <h1 align="center">Grape</h1>
</p>

<p align="center">
  <img src="https://github.com/li3zhen1/Grape/actions/workflows/swift.yml/badge.svg" alt="swift workflow">
  <a href="https://swiftpackageindex.com/li3zhen1/Grape">
  <img src="https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fli3zhen1%2FGrape%2Fbadge%3Ftype%3Dplatforms" alt="swift package index">
  </a>
  <a href="https://swiftpackageindex.com/li3zhen1/Grape">
  <img src="https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fli3zhen1%2FGrape%2Fbadge%3Ftype%3Dswift-versions" alt="swift package index">
  </a>
</p>

<p align="center">A Swift library for force simulation and graph visualization.<img width="712" alt="ForceDirectedGraphLight" src="https://github.com/li3zhen1/Grape/assets/45376537/e0e8049d-25c2-4e5c-9623-6bf43ddddfa5"></p>






### Examples

This is a force directed graph visualizing the data from [Force Directed Graph Component](https://observablehq.com/@d3/force-directed-graph-component), running at 120FPS on a SwiftUI Canvas. Take a closer look at the animation:

https://github.com/li3zhen1/Grape/assets/45376537/6a1c9510-8af6-4967-9c05-c304b2af59ee


### Features

|   | 2D simd | ND simd | Metal |
| --- | --- | --- | --- |
| **NdTree** | ✅ | ✅ |  |
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


### Credits

This library has been greatly influenced by the outstanding work done by [D3.js (Data-Driven Documents)](https://d3js.org).
