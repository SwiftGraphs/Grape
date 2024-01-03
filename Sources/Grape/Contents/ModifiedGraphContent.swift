import SwiftUI

public struct ModifiedGraphContent<C, M> where C: GraphContent, M: GraphContentModifier {

    @usableFromInline
    let content: C

    @usableFromInline
    let modifier: M

    @inlinable
    public init(
        _ content: C,
        _ modifier: M
    ) {
        self.content = content
        self.modifier = modifier
    }
}

// public struct ModifiedGraphContent_Environment<C, T> where C: GraphContent {
//     @usableFromInline
//     let content: C

//     @usableFromInline
//     let keyPath: WritableKeyPath<_Grape.Environment, T>

//     @usableFromInline
//     let value: T

//     @inlinable
//     init(
//         _ content: C,
//         _ keyPath: WritableKeyPath<_Grape.Environment, T>,
//         _ value: T
//     ) {
//         self.content = content
//         self.keyPath = keyPath
//         self.value = value
//     }
// }

extension ModifiedGraphContent: GraphContent {
    public typealias NodeID = C.NodeID

    @inlinable
    public func _attachToGraphRenderingContext(_ context: inout _GraphRenderingContext<NodeID>) {
        modifier._into(&context)
        content._attachToGraphRenderingContext(&context)
        modifier._exit(&context)
    }
}
