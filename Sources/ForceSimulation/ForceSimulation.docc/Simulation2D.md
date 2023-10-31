# ``ForceSimulation/Simulation2D``

A force-simulation for distributed layout within a two-dimensional space.

## Topics

### Creating a 2D force simulation

- ``init(nodeIds:alpha:alphaMin:alphaDecay:alphaTarget:velocityDecay:setInitialStatus:)``

### Creating forces for the simulation

- ``createCenterForce(center:strength:)``
- ``CenterForce``
- ``createCollideForce(radius:strength:iterationsPerTick:)``
- ``CollideForce``
- ``createLinkForce(_:stiffness:originalLength:iterationsPerTick:)-652gu``
- ``createLinkForce(_:stiffness:originalLength:iterationsPerTick:)-9iwy5``
- ``LinkForce``
- ``createManyBodyForce(strength:nodeMass:)``
- ``ManyBodyForce``
- ``createPositionForce(direction:targetOnDirection:strength:)``
- ``DirectionForce2D``
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
