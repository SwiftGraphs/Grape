# ``ForceSimulation``

Run force simulation within any number of dimensions.

## Overview

The `ForceSimulation` library enables you to create any dimensional simulation that uses velocity Verlet integration.

For more information on force simulations, read: [Force simulations - D3](https://d3js.org/d3-force/simulation). 


@Image(source: "ForceDirectedGraph.png", alt: "An example of 2D force directied graph.")



## Topics

### Creating a simulation

* <doc:Creating2DAnd3DSimulations>
* ``Simulation2D``
* ``Simulation3D``
* ``SimulationKD``

### Spatial data structures

- ``Quadtree``
- ``QuadtreeDelegate``
- ``QuadBox``
- ``Octree``
- ``OctreeDelegate``
- ``OctBox``
- ``NDTree``
- ``NDTreeDelegate``
- ``NDBox``
- ``EdgeID``

### Deterministic Randomness

- ``FloatLinearCongruentialGenerator``
- ``LinearCongruentialGenerator``

### Supporting Protocols

- ``ForceLike``
- ``NDTreeBasedForceLike``
- ``VectorLike``
- ``SimulatableFloatingPoint``

### Error Types

- ``ManyBodyForce2DError``
