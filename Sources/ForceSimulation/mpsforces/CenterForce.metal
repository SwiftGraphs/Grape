#include <metal_stdlib>
using namespace metal;

struct Node {
    float2 position;
    float2 velocity;
    float2 fixation;
};

kernel void applyCenterForce(
    device Node* nodes [[ buffer(0) ]],
    constant float2& center [[ buffer(1) ]],
    constant float& strength [[ buffer(2) ]],
    uint id [[ thread_position_in_grid ]],
    uint nodeCount [[ threads_per_grid ]])
{
    float2 meanPosition = float2(0.0, 0.0);
    for (int i = 0; i < nodeCount; ++i) {
        meanPosition += nodes[i].position;
    }
    meanPosition /= float(nodeCount);

    float2 delta = (meanPosition - center) * strength;
    nodes[id].position -= delta;
}
