import SwiftUI

extension EnvironmentValues {
    @usableFromInline
    var graphForegroundScaleEnvironment: [AnyHashable: GraphicsContext.Shading]
    {
        get {
            self[__Key_graphForegroundScaleEnvironment.self]
        }
        set {
            self[__Key_graphForegroundScaleEnvironment.self] = newValue
        }
    }
    
    private struct __Key_graphForegroundScaleEnvironment: SwiftUICore.EnvironmentKey {
        typealias Value = [AnyHashable: GraphicsContext.Shading]
        static var defaultValue: Value { [:] }
    }
}

@usableFromInline
struct GraphEnvironmentViewModifier: ViewModifier {

    @usableFromInline
    let colorScale: [AnyHashable: GraphicsContext.Shading]

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
