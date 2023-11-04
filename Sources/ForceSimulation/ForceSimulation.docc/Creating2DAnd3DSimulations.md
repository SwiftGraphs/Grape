# Creating 2D and 3D simulations 


## Overview

Create 2D or 3D simulations by using Simulation2D or Simulation3D.
For example, the following code creates a 2D force simulation.

```swift

import ForceSimulation

struct Node: Identifiable { ... }

let nodeIds: [Node.ID] = ... 
let links: [(Node.ID, Node.ID)] = ... 

let simulation = Simulation2D(nodeIds: nodeIds, alphaDecay: 0.01)
                        .withManyBodyForce(strength: -12)
                        .withLinkForce(
                            links,
                            stiffness: .weightedByDegree { _, _ in 1.0 },
                            originalLength: .constant(35)
                        )
                        .withCenterForce(center: .zero, strength: 0.4)
                        .withCollideForce(radius: .constant(3.0))

/// Force is ready to start! run `tick` to iterate the simulation.

for i in 0..<120 {
    simulation.tick()
    let positions = simulation.nodePositions
    /// Do something with the positions.
}
```

Adding forces changes the type signature of the simulation. You can use opaque types.

```swift

let simulation: Simulation<Node.ID, > = Simulation2D(nodeIds: nodeIds, alphaDecay: 0.01)
                        .withManyBodyForce(strength: -12)

```


See [Examples](https://github.com/li3zhen1/Grape/tree/main/Examples) for example Xcode projects.
