import SwiftUI

extension GraphContentEffect {
    @usableFromInline
    internal struct Label {
        @usableFromInline
        let text: Text

        @inlinable
        public init(_ text: Text) {
            self.text = text
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
            context.symbols[resolvedText] = text.toCGImage(scaledBy: context.states.displayScale)
        }
    }
}
