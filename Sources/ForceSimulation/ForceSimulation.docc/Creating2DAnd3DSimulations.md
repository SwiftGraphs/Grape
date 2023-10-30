# Creating 2D and 3D simulations 


## Overview

You can simply create 2D or 3D simulations by using Simulation2D or Simulation3D:

```swift

import ForceSimulation

struct Node: Identifiable { ... }

let nodeIds: [Node.ID] = ... 
let links: [(Node.ID, Node.ID)] = ... 

let sim = Simulation2D(nodeIds: nodeIds, alphaDecay: 0.01)
sim.createManyBodyForce(strength: -12)
sim.createLinkForce(links)
sim.createCenterForce(center: [0, 0], strength: 0.4)
sim.createCollideForce(radius: .constant(3))

/// Force is ready to start! run `tick` to iterate the simulation.

for i in 0..<120 {
    sim.tick()
    let positions = sim.nodePositions
    /// Do something with the positions.
}

```

See [Example](https://github.com/li3zhen1/Grape/tree/main/Examples/ForceDirectedGraphExample) for more details.