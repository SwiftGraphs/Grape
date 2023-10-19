<p align="center">
  <img alt="grape-icon" src="https://github.com/li3zhen1/Grape/assets/45376537/4ab08ea1-22e6-4fe8-ab2b-99ae325b46a6" height="96">
  <h1 align="center">Grape</h1>

</p>

<p align="center">
  <img src="https://github.com/li3zhen1/Grape/actions/workflows/swift.yml/badge.svg" alt="swift workflow">
  <a href="https://swiftpackageindex.com/li3zhen1/Grape"><img src="https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fli3zhen1%2FGrape%2Fbadge%3Ftype%3Dswift-versions" alt="swift package index"></a>
  <a href="https://swiftpackageindex.com/li3zhen1/Grape"><img src="https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fli3zhen1%2FGrape%2Fbadge%3Ftype%3Dplatforms" alt="swift package index"></a>

</p>

<p align="center">A Swift library for force simulation and graph visualization.
  <img width="712" alt="ForceDirected" src="https://github.com/li3zhen1/Grape/assets/45376537/1cbc938e-55a8-438e-b20b-3e52577ac30a">
</p>






## Examples

### Force Directed Graph
This is a force directed graph visualizing the data from [Force Directed Graph Component](https://observablehq.com/@d3/force-directed-graph-component), iterating at 120FPS. Take a closer look at the animation:

https://github.com/li3zhen1/Grape/assets/45376537/ea1ccea3-5717-4cfe-a696-c89e75ca9d3b

<br/>

### Lattice Simulation

This is a 30x30 force directed lattice like [Force Directed Lattice](https://observablehq.com/@d3/force-directed-lattice):

https://github.com/li3zhen1/Grape/assets/45376537/86c6b155-105f-44d8-a280-de70f55fefd2



<br/>


## Features

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

## Usage

### Basic

The basic concepts of simulations and forces can be found here: [Force simulations - D3](https://d3js.org/d3-force/simulation). You can simply create 2D or 3D simulations by using `Simulation2D` or `Simulation3D`:

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

/// Force is ready to start! run `tick` to iterate the simulation.

for i in 0..<120 {
    sim.tick()
    let positions = sim.nodePositions
    /// Do something with the positions.
}

```

See [Example](https://github.com/li3zhen1/Grape/tree/main/Examples/ForceDirectedGraphExample) for more details. 

<br/>

### Advanced

Grape currently includes 2 packages, `NDTree` and `ForceSimulation`. `NDTree` is a N-dimensional tree data structure, which is used to accelerate the force simulation. `ForceSimulation` is a force simulation library, which is used to simulate the force between nodes in a graph. Both of them are generic types that work with any SIMD-like data structures. 

To integrate Grape into platforms where `import simd` isn't supported, you need to create a struct conforming to the `VectorLike` protocol. For ease of use, it's also recommended to add some type aliases. Here’s how you can do it:

```swift
/// All required implementations should have same semantics
/// as the SIMD protocol provided in Foundation.
struct SuperCool4DVector: VectorLike { ... }

public protocol HyperoctreeDelegate: NDTreeDelegate where V == SuperCool4DVector {}
public typealias HyperoctBox = NDBox<SuperCool4DVector>
public typealias Hyperoctree<TD: HyperoctreeDelegate> = NDTree<SuperCool4DVector, TD>

public typealias Simulation4D<NodeID> = Simulation<NodeID, Vector4d> where NodeID: Hashable
```

Also, this is how you create a 4D simulation with or without `simd_double4`. (Though I don't know what good it does)


<br/>

## Performance

Grape uses simd to calculate position and velocity. Currently it takes ~0.12 seconds to iterate 120 times over the example graph(2D). (77 vertices, 254 edges, with manybody, center, collide and link forces. Release build on a M1 Max)

Due to the iteration over simd lanes, going 3D will hurt performance. (~0.16 seconds for the same graph and same configs.)


<br/>

## Credits

This library has been greatly influenced by the outstanding work done by [D3.js (Data-Driven Documents)](https://d3js.org).
