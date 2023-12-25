import SwiftUI
extension GraphContent {
    @inlinable
    public func foregroundStyle<S>(_ style: S) -> some GraphContent<NodeID> where S: ShapeStyle {
        return ModifiedGraphContent(self, GrapeEffect.ForegroundStyle(style))
    }

    @inlinable
    public func opacity(_ value: Double) -> some GraphContent<NodeID> {
        return ModifiedGraphContent(self, GrapeEffect.Opacity(value))
    }
}