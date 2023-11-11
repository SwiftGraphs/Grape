# Creating a Simulation with Built-in Forces



## Overview

ForceSimulation module mainly contains 3 concepts, Kinetics, ForceProtocol and Simulation.

@Image(source: "SimulationDiagram.svg", alt: "A diagram showing the relationships of `Kinetics`, `ForceProtocol` and `Simulation`. A `Simulation` contains a `Kinetics` and a `ForceProtocol`.")

A diagram showing the relationships of `Kinetics`, `ForceProtocol` and `Simulation`. A `Simulation` contains a `Kinetics` and a `ForceProtocol`.

- Kinetics describes all kinetic states of your system, i.e. position, velocity, link connections, and the variable alpha that describes how "active" your system is.

- Forces are any types that conforms to ForceProtocol. This module provides most of the forces you will use in force directed graphs. And you can also create your own forces. They should be responsible for 2 tasks:

    - bindKinetics(_ kinetics: Kinetics<Vector>): binding to a Kinetics. In most cases the force should keep a reference of the Kinetics so they know what to mutate when apply is called.

    - apply(): Mutating the states of Kinetics. For example, a gravity force should add velocities on each node in this function.

- Simulation is a shell class you interact with, which enables you to create any dimensional simulation with velocity Verlet integration. It manages a Kinetics and a force conforming to ForceProtocol. Since Simulation only stores one force, you are responsible for compositing multiple forces into one.

- Another data structure KDTree is used to accelerate the force simulation with Barnes-Hut Approximation.

You can simply create simulations by using Simulation like this:

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

In this example, we run our simulation in a 2D space (`SIMD2<Double>`). We explicitly create a `SealedForce2D` to make sure the force is in the same dimension as the Kinetics. The `Vector` in `Simulation` is inferred from the force we pass.

See [Examples](https://github.com/li3zhen1/Grape/tree/main/Examples) for example Xcode projects.