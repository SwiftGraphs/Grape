public struct Dimension<NodeID, V>
where NodeID: Hashable, V: SIMD, V.Scalar: FloatingPoint {}