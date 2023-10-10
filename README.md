# Grape

![swift workflow](https://github.com/li3zhen1/Grape/actions/workflows/swift.yml/badge.svg)


A visualization-purposed force simulation library.




![Force Directed Graph](./Assets/ForceDirectedGraph.png)


#### Examples

This is a force directed graph visualizing the data from [Force Directed Graph Component](https://observablehq.com/@d3/force-directed-graph-component), running at 120FPS on a SwiftUI Canvas. Take a closer look at the animation! 

https://github.com/li3zhen1/Grape/assets/45376537/0a494ca0-7b98-44d0-a917-6dcc18e2eeae




#### Features

| Feature | Status |
| --- | --- |
| LinkForce | ✅ |
| ManyBodyForce | ✅ |
| CenterForce | ✅ |
| CollideForce | ✅ |
| PositionForce |  |
| RadialForce | ✅ |


#### Usage

```swift
import ForceSimulation

// nodes with unique id
let nodes: [Identifiable] = ... 

// links with source and target, ID should be the same as the type of the id
let links: [(ID, ID)] = ... 

let sim = Simulation(nodes: nodes, alphaDecay: 0.0005)
sim.createManyBodyForce(strength: -30)
sim.createLinkForce(links: links, originalLength: .constant(35))
sim.createCenterForce(center: .zero, strength: 0.1)
sim.createCollideForce(radius: .constant(5))

```

See [Example](https://github.com/li3zhen1/Grape/tree/main/Examples/GrapeView) for more details.

#### Perfomance

Currently it takes 0.046 seconds to iterate 120 times over the example graph (with 77 vertices, 254 edges, with manybody, center and link forces, release build, on a 32GB M1 Max).
