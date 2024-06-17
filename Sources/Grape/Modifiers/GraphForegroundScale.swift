import SwiftUI

@usableFromInline
enum GrapeEnvironment { }


extension GrapeEnvironment {
    @usableFromInline
    struct GraphForegroundScale: EnvironmentKey {
        @usableFromInline
        static nonisolated(unsafe) let defaultValue: [AnyHashable: GraphicsContext.Shading] = [:]
    }
}

extension EnvironmentValues {
    @inlinable
    var graphForegroundScaleEnvironment: GrapeEnvironment.GraphForegroundScale.Value {
        get { self[GrapeEnvironment.GraphForegroundScale.self] }
        set { self[GrapeEnvironment.GraphForegroundScale.self] = newValue }
    }
}

@usableFromInline
struct GraphEnvironmentViewModifier: ViewModifier {

    @usableFromInline
    let colorScale: Dictionary<AnyHashable, GraphicsContext.Shading>

    @inlinable
    init<DataValue, S>(_ mapping: KeyValuePairs<DataValue, S>) where S: ShapeStyle, DataValue: Hashable {
        var colorScale: [AnyHashable: GraphicsContext.Shading] = [:]
        mapping.forEach {
            colorScale[.init($0.0)] = .style($0.1)
        }
        self.colorScale = colorScale
    }

    @inlinable
    func body(content: Content) -> some View {
        content
            .environment(\.graphForegroundScaleEnvironment, colorScale)
    }
}

extension View {
    @inlinable
    func graphForegroundStyleScale<DataValue, S>(_ mapping: KeyValuePairs<DataValue, S>) -> some View where S: ShapeStyle, DataValue: Hashable {
        return modifier(GraphEnvironmentViewModifier(mapping))
    }
}
