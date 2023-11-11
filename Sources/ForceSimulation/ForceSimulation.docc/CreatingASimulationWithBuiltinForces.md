# Creating a Simulation with Built-in Forces





## Overview

Create 2D or 3D simulations by using Simulation2D or Simulation3D.
For example, the following code creates a 2D force simulation.

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

See [Examples](https://github.com/li3zhen1/Grape/tree/main/Examples) for example Xcode projects.