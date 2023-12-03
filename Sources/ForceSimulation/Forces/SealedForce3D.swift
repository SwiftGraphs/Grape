
/// A force that can be composed of one or multiple forces. The forces you can add
/// here include:
/// - `Kinetics3D.CenterForce`
/// - `Kinetics3D.RadialForce`
/// - `Kinetics3D.ManyBodyForce`
/// - `Kinetics3D.LinkForce`
/// - `Kinetics3D.CollideForce`
/// - `Kinetics3D.PositionForce`
/// - `Kinetics3D.EmptyForce`
/// 
/// If you want to add a custom force, checkout `CompositedForce`.
public struct SealedForce3D: Force3D {

    public var entries: [ForceEntry] = []

    @inlinable
    public func apply() {
        for force in self.entries {
            force.apply()
        }
    }
    
    @inlinable
    public func dispose() {
        for force in self.entries {
            force.dispose()
        }
    }

    @inlinable
    public init(
        _ entries: [ForceEntry]
    ) {
        self.entries = entries
    }

    @inlinable
    public mutating func bindKinetics(_ kinetics: Kinetics<SIMD3<Float>>) {
        self.entries = self.entries.map { entry in
            switch entry {
            case .center(var force):
                force.bindKinetics(kinetics)
                return .center(force)
            case .radial(var force):
                force.bindKinetics(kinetics)
                return .radial(force)
            case .manyBody(var force):
                force.bindKinetics(kinetics)
                return .manyBody(force)
            case .link(var force):
                force.bindKinetics(kinetics)
                return .link(force)
            case .collide(var force):
                force.bindKinetics(kinetics)
                return .collide(force)
            case .position(var force):
                force.bindKinetics(kinetics)
                return .position(force)
            default:
                return entry
            }
        }
    }

    public enum ForceEntry {
        case center(Kinetics3D.CenterForce)
        case radial(Kinetics3D.RadialForce)
        case manyBody(Kinetics3D.ManyBodyForce)
        case link(Kinetics3D.LinkForce)
        case collide(Kinetics3D.CollideForce)
        case position(Kinetics3D.PositionForce)
        case empty

        @inlinable
        public func apply() {
            switch self {
            case .center(let force):
                force.apply()
            case .radial(let force):
                force.apply()
            case .manyBody(let force):
                force.apply()
            case .link(let force):
                force.apply()
            case .collide(let force):
                force.apply()
            case .position(let force):
                force.apply()
            default:
                break
            }
        }
        
        @inlinable
        public func dispose() {
            switch self {
            case .center(let force):
                force.dispose()
            case .radial(let force):
                force.dispose()
            case .manyBody(let force):
                force.dispose()
            case .link(let force):
                force.dispose()
            case .collide(let force):
                force.dispose()
            case .position(let force):
                force.dispose()
            default:
                break
            }
        }
    }

    @inlinable
    public init(@SealedForce3DBuilder _ builder: () -> [ForceEntry]) {
        self.entries = builder()
    }

}


@resultBuilder
public struct SealedForce3DBuilder {
    public static func buildBlock(_ components: SealedForce3D.ForceEntry...) -> [SealedForce3D.ForceEntry] {
        components
    }

    public static func buildExpression<FD>(_ expression: FD) -> SealedForce3D.ForceEntry where FD: ForceDescriptor, FD.ConcreteForce: Force3D {
        let f = expression.createForce()
        switch f {
        case let f as Kinetics3D.CenterForce:
            return .center(f)
        case let f as Kinetics3D.RadialForce:
            return .radial(f)
        case let f as Kinetics3D.ManyBodyForce:
            return .manyBody(f)
        case let f as Kinetics3D.LinkForce:
            return .link(f)
        case let f as Kinetics3D.CollideForce:
            return .collide(f)
        case let f as Kinetics3D.PositionForce:
            return .position(f)
        default:
            return .empty
        }
    }

    public static func buildExpression<F>(_ f: F) -> SealedForce3D.ForceEntry where F:Force3D {
        switch f {
        case let f as Kinetics3D.CenterForce:
            return .center(f)
        case let f as Kinetics3D.RadialForce:
            return .radial(f)
        case let f as Kinetics3D.ManyBodyForce:
            return .manyBody(f)
        case let f as Kinetics3D.LinkForce:
            return .link(f)
        case let f as Kinetics3D.CollideForce:
            return .collide(f)
        case let f as Kinetics3D.PositionForce:
            return .position(f)
        default:
            return .empty
        }
    }
}
