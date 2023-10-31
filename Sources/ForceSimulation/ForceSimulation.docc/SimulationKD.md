# ``ForceSimulation/SimulationKD``

A force-simulation for distributed layout within a multi-dimensional space.

## Topics

### Creating a multi-dimensional force simulation

- ``init(nodeIds:alpha:alphaMin:alphaDecay:alphaTarget:velocityDecay:setInitialStatus:)``

### Creating forces for the simulation

- ``createCenterForce(center:strength:)``
- ``CenterForce``
- ``createCollideForce(radius:strength:iterationsPerTick:)``
- ``CollideForce``
- ``createLinkForce(_:stiffness:originalLength:iterationsPerTick:)-46ea4``
- ``createLinkForce(_:stiffness:originalLength:iterationsPerTick:)-9opzo``
- ``LinkForce``
- ``createManyBodyForce(strength:nodeMass:)``
- ``ManyBodyForce``
- ``createPositionForce(direction:targetOnDirection:strength:)``
- ``DirectionForce``
- ``createRadialForce(center:radius:strength:)``
- ``RadialForce``

### Running the simulation

- ``tick(iterationCount:)``
- ``resetAlpha(_:)``

### Inspecting the simulation

- ``alpha``
- ``alphaMin``
- ``alphaDecay``
- ``alphaTarget``
- ``initializedAlpha``
- ``velocityDecay``
- ``forces``

### Inspecting nodes within the simulation

- ``nodeIds``
- ``nodeFixations``
- ``nodePositions``
- ``nodeVelocities``
- ``getIndex(of:)``
