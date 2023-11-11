# ``ForceSimulation``

Run force simulation within any number of dimensions.

## Overview

The `ForceSimulation` library enables you to create any dimensional simulation that uses velocity Verlet integration.



@Image(source: "ForceDirectedGraph.png", alt: "An example of 2D force directied graph.")


For more information on force simulations, read: [Force simulations - D3](https://d3js.org/d3-force/simulation). 


## Topics

### Creating a simulation

* <doc:CreatingASimulationWithBuiltinForces>

* ``Simulation``
* ``Kinetics``
* ``EdgeID``

### Built-in forces

* ``Kinetics/LinkForce``
* ``Kinetics/ManyBodyForce``
* ``Kinetics/CenterForce``
* ``Kinetics/CollideForce``
* ``Kinetics/PositionForce``
* ``Kinetics/RadialForce``
* ``Kinetics/EmptyForce``

### Utility forces for compositing a force field

* ``ForceField``
* ``SealedForce2D``
* ``CompositedForce``



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

