# ``ForceSimulation``

Run force simulation within any number of dimensions.

## Overview

The `ForceSimulation` library enables you to create any dimensional simulation that uses velocity Verlet integration.

For more information on force simulations, read: [Force simulations - D3](https://d3js.org/d3-force/simulation). 


@Image(source: "ForceDirectedGraph.png", alt: "An example of 2D force directied graph.")



## Topics

### Creating a simulation

* <doc:Creating2DAnd3DSimulations>

* ``Simulation``
* ``Kinetics``
* ``EdgeID``

### Built-in forces

* ``Kinetics.ManyBodyForce``
* ``Kinetics.LinkForce``
* ``Kinetics.CenterForce``
* ``Kinetics.CollideForce``
* ``Kinetics.PositionForce``
* ``Kinetics.RadialForce``

### Utility forces for compositing a force field

* ``ForceField``
* ``SealedForce2D``
* ``CompositedForce``
* ``Kinetics.EmptyForce``



### Spatial partitioning data structures

- ``KDTree``
- ``KDBox``
- ``KDTreeDelegate``

### Deterministic randomness


- ``SimulatableFloatingPoint``
- ``DeterministicRandomGenerator``
- ``HasDeterministicRandomGenerator``
- ``DoubleLinearCongruentialGenerator``
- ``FloatLinearCongruentialGenerator``


### Supporting protocols

- ``ForceProtocol``

### Utilities

- ``SimulatableVector``

