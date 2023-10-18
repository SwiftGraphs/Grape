<p align="center">
  <img alt="grap-icon" src="https://github.com/li3zhen1/Grape/assets/45376537/0e23c50e-9b2c-4c3f-ad59-9ae03773ab78" height="96">
  <h1 align="center">Grape</h1>
</p>

<p align="center">
  <img src="https://github.com/li3zhen1/Grape/actions/workflows/swift.yml/badge.svg" alt="swift workflow">
  <a href="https://swiftpackageindex.com/li3zhen1/Grape">
  <img src="https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fli3zhen1%2FGrape%2Fbadge%3Ftype%3Dswift-versions" alt="swift package index">
  </a>
  <a href="https://swiftpackageindex.com/li3zhen1/Grape">
  <img src="https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fli3zhen1%2FGrape%2Fbadge%3Ftype%3Dplatforms" alt="swift package index">
  </a>

</p>

<p align="center">A Swift library for force simulation and graph visualization.
<img width="1355" alt="ForceDirected" src="https://github.com/li3zhen1/Grape/assets/45376537/800a2dd6-18d4-493f-a971-6cd1164aeb11"></p>



<br/>
<br/>



### Examples

This is a force directed graph visualizing the data from [Force Directed Graph Component](https://observablehq.com/@d3/force-directed-graph-component), running at 120FPS on a SwiftUI Canvas. Take a closer look at the animation:

https://github.com/li3zhen1/Grape/assets/45376537/ea1ccea3-5717-4cfe-a696-c89e75ca9d3b


<br/>
<br/>


### Features

|   | 2D simd | ND simd | Metal |
| --- | --- | --- | --- |
| **NdTree** | ✅ | ✅ |  |
| **Simulation** | ✅ | ✅ |  |
| &emsp;LinkForce | ✅ | ✅ |  |
| &emsp;ManyBodyForce | ✅ | ✅ |  |
| &emsp;CenterForce | ✅ | ✅ |  |
| &emsp;CollideForce | ✅ | ✅ |  |
| &emsp;PositionForce | ✅ | ✅ |  |
| &emsp;RadialForce | ✅ | ✅ |  |
| **SwiftUI View** | 🚧 |  |  |


<br/>
<br/>

### Usage

Grape currently include 2 packages, `NDTree` and `ForceSimulation`. `NDTree` is a N-dimensional tree data structure, which is used to accelerate the force simulation. `ForceSimulation` is a force simulation library, which is used to simulate the force between nodes in a graph. Both of them are based on SIMD-like data structures. 

The package specifically exposes concrete types for 2D and 3D simulation, so you can create a 2D simulation like this:

```swift
import NDTree
import ForceSimulation

struct Node: Identifiable { ... }

let nodeIds: [Node.ID] = ... 
let links: [(Node.ID, Node.ID)] = ... 

let sim = Simulation2D(nodeIds: nodeIds, alphaDecay: 0.01)
sim.createManyBodyForce(strength: -12)
sim.createLinkForce(links)
sim.createCenterForce(center: Vector2d(0, 0), strength: 0.4)
sim.createCollideForce(radius: .constant(3))
```

See [Example](https://github.com/li3zhen1/Grape/tree/main/Examples/ForceDirectedGraphExample) for more details. Documentations will be added soon.


<br/>
<br/>

### Performance

Grape uses simd to calculate position and velocity. Currently it takes ~0.12 seconds to iterate 120 times over the example graph(2D). (77 vertices, 254 edges, with manybody, center, collide and link forces. Release build on a M1 Max)

Due to the iteration over simd lanes, going 3D will hurt performance. (~0.19 seconds for the same graph and same configs.)


<br/>
<br/>

### Credits

This library has been greatly influenced by the outstanding work done by [D3.js (Data-Driven Documents)](https://d3js.org).
