import CoreGraphics
import SwiftUI

#if canImport(AppKit)
    import AppKit
    @inlinable
    internal func getDisplayScale() -> CGFloat {
        return NSScreen.main?.backingScaleFactor ?? 2.0
    }
#elseif canImport(UIKit)
    import UIKit
    @inlinable
    internal func getDisplayScale() -> CGFloat {
        return UIScreen.main.scale
    }
#else
    @inlinable
    internal func getDisplayScale() -> CGFloat {
        return 2.0
    }
#endif

// #if os(macOS)
//     import AppKit
//     @inlinable
//     func getCGContext() -> CGContext? {
//         return NSGraphicsContext.current?.cgContext
//     }
// #elseif os(iOS)
//     import UIKit
//     @inlinable
//     func getCGContext() -> CGContext? {
//         return UIGraphicsGetCurrentContext()
//     }
// #endif

// class CLD: NSObject, CALayerDelegate {
//     func draw(_ layer: CALayer, in ctx: CGContext) {
//         let text = "Hello World!"
//         let font = NSFont.systemFont(ofSize: 72)
//         let attributes = [NSAttributedString.Key.font: font]
//         let attributedString = NSAttributedString(string: text, attributes: attributes)
//         let line = CTLineCreateWithAttributedString(attributedString)
//         let bounds = CTLineGetBoundsWithOptions(line, CTLineBoundsOptions.useOpticalBounds)
//         ctx.textMatrix = .identity
//         ctx.translateBy(x: 0, y: bounds.height)
//         ctx.scaleBy(x: 1.0, y: -1.0)
//         CTLineDraw(line, ctx)
//     }
// }

extension View {
    @inlinable
    @MainActor
    internal func toCGImage(scaledBy factor: CGFloat) -> CGImage? {
        let renderer = ImageRenderer(
            content: self
        )
        renderer.scale = factor
        // guard let image = renderer.nsImage else { return nil }
        // var imageRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        // let imageRef = image.cgImage(forProposedRect: &imageRect, context: nil, hints: nil)
        return renderer.cgImage
    }

    @inlinable
    @MainActor
    internal func toCGImage(with environment: EnvironmentValues, antialias: Double = 1.5) -> CGImage? {
        let renderer = ImageRenderer(
            content: self.environment(\.self, environment)
        )
        renderer.scale = environment.displayScale * antialias
        
        // guard let image = renderer.nsImage else { return nil }
        // var imageRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        // let imageRef = image.cgImage(forProposedRect: &imageRect, context: nil, hints: nil)
        return renderer.cgImage
    }

    // @inlinable
    // @MainActor
    // internal func toCGImage() -> CGImage? {
    //     let uicont
    //     return renderer.cgImage
    // }

    // @inlinable
    // @MainActor
    // public func toCALayer() -> CALayer? {
    //     let renderer = ImageRenderer(content: self)
    //     if let context = getCGContext() {
    //         renderer.render(rasterizationScale: 2.0) { size, render in
    //             let caLayer = CALayer
    //         }
    //     }
    //     return renderer.cgImage
    // }
}

extension Text {
    @inlinable
    internal func resolved() -> String {
        // This is an undocumented API
        return self._resolveText(in: Self.resolvingEnvironment)
    }

    @inlinable
    static internal var resolvingEnvironment: EnvironmentValues {
        return EnvironmentValues()
    }

}
