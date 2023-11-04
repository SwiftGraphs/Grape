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
* ``Simulation2D``
* ``Simulation3D``

* ``SimulationState``

### Creating forces
* ``LinkForce``
* ``ManyBodyForce``
* ``CenterForce``
* ``CollideForce``
* ``DirectionForce``
* ``RadialForce``


### Creating custom forces
* ``ForceProtocol`` 
* ``EmptyForce``
* ``ForceField``

### Spatial data structures

- ``Quadtree``
- ``QuadBox``
- ``Octree``
- ``OctBox``
- ``NDTree``
- ``NDTreeDelegate``
- ``NDBox``


### Deterministic Randomness

- ``FloatLinearCongruentialGenerator``
- ``LinearCongruentialGenerator``

### Supporting Protocols

- ``ForceLike``
- ``NDTreeBasedForceLike``
- ``VectorLike``
- ``SimulatableFloatingPoint``

### Supporting Types
- ``EdgeID``

### Error Types

- ``SimulationError``
