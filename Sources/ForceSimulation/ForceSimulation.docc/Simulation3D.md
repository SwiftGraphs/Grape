# ``ForceSimulation/Simulation3D``

A force-simulation for distributed layout within a three-dimensional space.

## Topics

### Creating a 3D force simulation

- ``init(nodeIds:alpha:alphaMin:alphaDecay:alphaTarget:velocityDecay:setInitialStatus:)``

### Creating forces for the simulation

- ``createCenterForce(center:strength:)``
- ``CenterForce``
- ``createCollideForce(radius:strength:iterationsPerTick:)``
- ``CollideForce``
- ``createLinkForce(_:stiffness:originalLength:iterationsPerTick:)-2bixz``
- ``createLinkForce(_:stiffness:originalLength:iterationsPerTick:)-3sa2n``
- ``LinkForce``
- ``createManyBodyForce(strength:nodeMass:)``
- ``ManyBodyForce``
- ``createPositionForce(direction:targetOnDirection:strength:)``
- ``DirectionForce3D``
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
