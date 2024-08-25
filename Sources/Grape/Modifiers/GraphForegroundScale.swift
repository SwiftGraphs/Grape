import SwiftUI

extension EnvironmentValues {
    @usableFromInline
    @Entry
    var graphForegroundScaleEnvironment: [AnyHashable: GraphicsContext.Shading] = [:]
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
