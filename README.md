# Grape

![swift workflow](https://github.com/li3zhen1/Grape/actions/workflows/swift.yml/badge.svg)


A visualization-purposed force simulation library.


#### Examples

<img width="712" alt="ForceDirectedGraphLight" src="https://github.com/li3zhen1/Grape/assets/45376537/e0e8049d-25c2-4e5c-9623-6bf43ddddfa5">

This is a force directed graph visualizing the data from [Force Directed Graph Component](https://observablehq.com/@d3/force-directed-graph-component), running at 120FPS on a SwiftUI Canvas. Take a closer look at the animation:

https://github.com/li3zhen1/Grape/assets/45376537/5f57c223-0126-428a-a72d-d9a3ed38059d





#### Features

| Feature | Status |
| --- | --- |
| LinkForce | ✅ |
| ManyBodyForce | ✅ |
| CenterForce | ✅ |
| CollideForce | ✅ |
| PositionForce |  |
| RadialForce |  |


#### Perfomance

Currently iterating the example graph 120 times in release build takes 0.046 seconds on a 32GB M1 Max. (77 vertices, 254 edges, link, with manybody, center and link forces)
