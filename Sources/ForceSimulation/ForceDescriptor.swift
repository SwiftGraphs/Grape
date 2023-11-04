public protocol ForceDescriptor {}

public struct Center<V>: ForceDescriptor where V: SIMD, V.Scalar: FloatingPoint{
    public var center: V
    public var strength: V.Scalar
}
public struct ManyBody: ForceDescriptor {}
public struct Collision: ForceDescriptor {}
public struct Link: ForceDescriptor {}
public struct Position: ForceDescriptor {}
public struct Radial: ForceDescriptor {}

public struct Empty: ForceDescriptor {}
