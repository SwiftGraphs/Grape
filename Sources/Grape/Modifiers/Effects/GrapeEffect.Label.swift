import SwiftUI

extension GraphContentEffect {
    @usableFromInline
    internal struct Label {

        @usableFromInline
        let text: Text

        @usableFromInline
        let alignment: Alignment

        @usableFromInline
        let offset: CGVector

        @inlinable
        public init(
            _ text: Text,
            alignment: Alignment = .bottomLeading,
            offset: CGVector = .zero
        ) {
            self.text = text
            self.alignment = alignment
            self.offset = offset
        }
    }

}

extension GraphContentEffect.Label: GraphContentModifier {
    @inlinable
    public func _into<NodeID>(
        _ context: inout _GraphRenderingContext<NodeID>
    ) where NodeID: Hashable {

    }

    @inlinable
    @MainActor
    public func _exit<NodeID>(_ context: inout _GraphRenderingContext<NodeID>)
    where NodeID: Hashable {
        if let currentID = context.states.currentID {
            let resolvedText = text.resolved()
            context.resolvedTexts[currentID] = resolvedText
            context.symbols[resolvedText] = .pending(text)

            switch currentID {
            case .node(_):
                if let currentSymbolSize = context.states.currentSymbolSize {
                    let anchorOffset = alignment.anchorOffset(for: currentSymbolSize)
                    context.textOffsets[currentID] = (alignment, offset.simd + anchorOffset)
                } else {
                    context.textOffsets[currentID] = (alignment, offset.simd)
                }
            case .link(_, _):
                context.textOffsets[currentID] = (alignment, offset.simd)
            }
        }
    }
}

extension Alignment {
    @inlinable
    internal func anchorOffset(for size: CGSize) -> SIMD2<Double> {
        // vertical text ?
        switch vertical {
        case .top:
            return SIMD2(0, -Double(size.height) / 2)
        case .center:
            switch horizontal {
            case .leading:
                return SIMD2(Double(size.width) / 2, 0)
            case .trailing:
                return SIMD2(-Double(size.width) / 2, 0)
            default:    
                return .zero
            }
        case .bottom:
            return SIMD2(0, Double(size.height) / 2)
        default:
            return .zero
        }
    }

    @inlinable
    internal func textImageOffsetInCGContext(width: Double, height: Double) -> SIMD2<Double> {
        let dx: Double =
            switch horizontal {
            case .center: -width / 2
            case .trailing: -width
            case .leading: 0
            default: 0
            }
        let dy: Double =
            switch vertical {
            case .center: height / 2
            case .bottom: height
            case .top: 0
            default: 0
            }

        return SIMD2(dx, dy)
    }
}
