
/// A force that can be composed of one or multiple forces. The forces you can add
/// here include:
/// - `Kinetics2D.CenterForce`
/// - `Kinetics2D.RadialForce`
/// - `Kinetics2D.ManyBodyForce`
/// - `Kinetics2D.LinkForce`
/// - `Kinetics2D.CollideForce`
/// - `Kinetics2D.PositionForce`
/// - `Kinetics2D.EmptyForce`
/// 
/// If you want to add a custom force, checkout `CompositedForce`.
public struct SealedForce2D: Force2D {

    public var entries: [ForceEntry] = []

    @inlinable
    public func apply() {
        for force in self.entries {
            force.apply()
        }
    }

    @inlinable
    public func apply(to kinetics: inout Kinetics<SIMD2<Double>>) {
        for force in self.entries {
            force.apply(to: &kinetics)
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
    public mutating func bindKinetics(_ kinetics: Kinetics<SIMD2<Double>>) {
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
        case center(Kinetics2D.CenterForce)
        case radial(Kinetics2D.RadialForce)
        case manyBody(Kinetics2D.ManyBodyForce)
        case link(Kinetics2D.LinkForce)
        case collide(Kinetics2D.CollideForce)
        case position(Kinetics2D.PositionForce)
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


        @inlinable
        public func apply(to kinetics: inout Kinetics<SIMD2<Double>>) {
            switch self {
            case .center(let force):
                force.apply(to: &kinetics)
            case .radial(let force):
                force.apply(to: &kinetics)
            case .manyBody(let force):
                force.apply(to: &kinetics)
            case .link(let force):
                force.apply(to: &kinetics)
            case .collide(let force):
                force.apply(to: &kinetics)
            case .position(let force):
                force.apply(to: &kinetics)
            default:
                break
            }
        }
    }

    @inlinable
    public init(@SealedForce2DBuilder _ builder: () -> [ForceEntry]) {
        self.entries = builder()
    }

}


@resultBuilder
public struct SealedForce2DBuilder {
    public static func buildBlock(_ components: SealedForce2D.ForceEntry...) -> [SealedForce2D.ForceEntry] {
        components
    }

    public static func buildExpression<FD>(_ expression: FD) -> SealedForce2D.ForceEntry where FD: ForceDescriptor, FD.ConcreteForce: Force2D {
        let f = expression.createForce()
        switch f {
        case let f as Kinetics2D.CenterForce:
            return .center(f)
        case let f as Kinetics2D.RadialForce:
            return .radial(f)
        case let f as Kinetics2D.ManyBodyForce:
            return .manyBody(f)
        case let f as Kinetics2D.LinkForce:
            return .link(f)
        case let f as Kinetics2D.CollideForce:
            return .collide(f)
        case let f as Kinetics2D.PositionForce:
            return .position(f)
        default:
            return .empty
        }
    }

    public static func buildExpression<F>(_ f: F) -> SealedForce2D.ForceEntry where F:Force2D {
        switch f {
        case let f as Kinetics2D.CenterForce:
            return .center(f)
        case let f as Kinetics2D.RadialForce:
            return .radial(f)
        case let f as Kinetics2D.ManyBodyForce:
            return .manyBody(f)
        case let f as Kinetics2D.LinkForce:
            return .link(f)
        case let f as Kinetics2D.CollideForce:
            return .collide(f)
        case let f as Kinetics2D.PositionForce:
            return .position(f)
        default:
            return .empty
        }
    }
}
