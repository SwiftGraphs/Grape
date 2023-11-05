import SwiftUI

public protocol GraphContent {}

extension GraphContent {
    @inlinable
    public func foregroundStyle<S>(_ style: S) -> Self where S: ShapeStyle {
        return self
    }

    @inlinable
    func opacity(_ value: Double) -> Self {
        return self
    }
}
