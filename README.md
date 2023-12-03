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
This is a force directed graph visualizing the data from [Force Directed Graph Component](https://observablehq.com/@d3/force-directed-graph-component). Take a closer look at the animation:



https://github.com/li3zhen1/Grape/assets/45376537/d80dc797-1980-4755-85b9-18ee26e2a7ff



Source code: [Miserables.swift](https://github.com/li3zhen1/Grape/blob/main/Examples/ForceDirectedGraphExample/ForceDirectedGraphExample/Miserables.swift). 



<br/>

### Force Directed Graph in visionOS

This is the same graph as the first example, rendered in `RealityView`:



https://github.com/li3zhen1/Grape/assets/45376537/4585471e-2339-4aee-8f39-0c11fdfb6901



Source code: [ForceDirectedGraph3D/ContentView.swift](https://github.com/li3zhen1/Grape/blob/main/Examples/ForceDirectedGraph3D/ForceDirectedGraph3D/ContentView.swift).


<br/>

### Lattice Simulation

This is a 36x36 force directed lattice like [Force Directed Lattice](https://observablehq.com/@d3/force-directed-lattice):



https://github.com/li3zhen1/Grape/assets/45376537/5b76fddc-dd5c-4d35-bced-29c01269dd2b



Source code: [Lattice.swift](https://github.com/li3zhen1/Grape/blob/main/Examples/ForceDirectedGraphExample/ForceDirectedGraphExample/Lattice.swift)

<br/>
<br/>


## Get started

Grape ships 2 modules:

- The `Grape` module allows you to create force-directed graphs in SwiftUI Views.
- The `ForceSimulation` module is the underlying mechanism of `Grape`, and it helps you to create more complicated or customized force simulations. It also contains a `KDTree` data structure built with performance in mind, which can be useful for spatial partitioning tasks.

<br/>

### `Grape`

```swift
import Grape

struct MyGraph: View {
    @State var isRunning = true // start moving once appeared.
    
    var body: some View {
        ForceDirectedGraph(isRunning: $isRunning) {
            
            // Declare nodes and links like you would do in Swift Charts.
            NodeMark(id: 0, fill: .green)
            NodeMark(id: 1, fill: .blue)
            NodeMark(id: 2, fill: .yellow)
            for i in 0..<2 {
                LinkMark(from: i, to: i+1)
            }
            
        } forceField: {
            LinkForce()
            CenterForce()
            ManyBodyForce()
        }
    }
}
```

Below is another [example](https://github.com/li3zhen1/Grape/blob/main/Examples/ForceDirectedGraphExample/ForceDirectedGraphExample/MyRing.swift) rendering a ring with 60 vertices, with out-of-the-box dragging support:

https://github.com/li3zhen1/Grape/assets/45376537/73213e7f-73ee-44f3-9b3e-7e58355045d2





> [!IMPORTANT]
> `ForceDirectedGraph` is only a minimal working example. Please refer to the next section to create a more complex view.

<br/>



### `ForceSimulation`

`ForceSimulation` module mainly contains 3 concepts, `Kinetics`, `ForceProtocol` and `Simulation`.
<p align="center">
  <img src="https://raw.githubusercontent.com/li3zhen1/Grape/main/Assets/SimulationDiagram.svg" alt="A diagram showing the relationships of `Kinetics`, `ForceProtocol` and `Simulation`. A `Simulation` contains a `Kinetics` and a `ForceProtocol`.">
</p>

- `Kinetics` describes all kinetic states of your system, i.e. position, velocity, link connections, and the variable `alpha` that describes how "active" your system is.
- Forces are any types that conforms to `ForceProtocol`. This module provides most of the forces you will use in force directed graphs. And you can also create your own forces. They should be responsible for 2 tasks:
    - `bindKinetics(_ kinetics: Kinetics<Vector>)`: binding to a `Kinetics`. In most cases the force should keep a reference of the `Kinetics` so they know what to mutate when `apply` is called.
    - `apply()`: Mutating the states of `Kinetics`. For example, a gravity force should add velocities on each node in this function.
- `Simulation` is a shell class you interact with, which enables you to create any dimensional simulation with velocity Verlet integration. It manages a `Kinetics` and a force conforming to `ForceProtocol`. Since `Simulation` only stores one force, you are responsible for compositing multiple forces into one.
- Another data structure `KDTree` is used to accelerate the force simulation with [Barnes-Hut Approximation](https://jheer.github.io/barnes-hut/).

<br/>

The basic concepts of simulations and forces can be found here: [Force simulations - D3](https://d3js.org/d3-force/simulation). You can simply create simulations by using `Simulation` like this:

```swift
import simd
import ForceSimulation

// assuming you’re simulating 4 nodes
let nodeCount = 4 

// Connect them
let links = [(0, 1), (1, 2), (2, 3), (3, 0)] 

/// Create a 2D force composited with 4 primitive forces.
let myForce = SealedForce2D {
    // Forces are namespaced under `Kinetics<Vector>`
    // here we only use `Kinetics<SIMD2<Double>>`, i.e. `Kinetics2D`
    Kinetics2D.ManyBodyForce(strength: -30)
    Kinetics2D.LinkForce(
        stiffness: .weightedByDegree(k: { _, _ in 1.0 }),
        originalLength: .constant(35)
    )
    Kinetics2D.CenterForce(center: .zero, strength: 1)
    Kinetics2D.CollideForce(radius: .constant(3))
}

/// Create a simulation, the dimension is inferred from the force.
let mySimulation = Simulation(
    nodeCount: nodeCount,
    links: links.map { EdgeID(source: $0.0, target: $0.1) },
    forceField: myForce
) 

/// Force is ready to start! run `tick` to iterate the simulation.

for mySimulation in 0..<120 {
    mySimulation.tick()
    let positions = mySimulation.kinetics.position.asArray()
    /// Do something with the positions.
}

```

See [Example](https://github.com/li3zhen1/Grape/tree/main/Examples/ForceDirectedGraphExample) for more details. 

<br/>

<br/>


## Roadmap

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

## Performance

<br/>

#### Simulation

Grape uses simd to calculate position and velocity. Currently it takes **~0.005** seconds to iterate 120 times over the example graph(2D). (77 vertices, 254 edges, with manybody, center, collide and link forces. Release build on a M1 Max, [tested](https://github.com/li3zhen1/Grape/blob/main/Tests/ForceSimulationTests/MiserableGraphTest.swift) with command `swift test -c release`)

For 3D simulation, it takes **~0.008** seconds for the same graph and same configs.

> [!IMPORTANT]
> Due to heavy use of generics (some are not specialized in Debug mode), the performance in Debug build is ~100x slower than Release build. Grape might ship a version with pre-inlined generics to address this problem.

<br/>

#### KDTree
The `BufferedKDTree` from this package is **~22x** faster than `GKQuadtree` from Apple’s GameKit, according to this [test case](https://github.com/li3zhen1/Grape/blob/main/Tests/ForceSimulationTests/GKTreeCompareTest.swift). However, please note that comparing Swift structs with NSObjects is unfair, and their behaviors are different.


<br/>

## Credits

This library has been greatly influenced by the outstanding work done by [D3.js (Data-Driven Documents)](https://d3js.org).
