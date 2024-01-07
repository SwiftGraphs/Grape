import SwiftUI

public protocol LinkShape {
    @inlinable
    func path(from: CGPoint, to: CGPoint) -> Path

    @inlinable
    func decoration(from: CGPoint, to: CGPoint) -> Path?
}

extension LinkShape {
    @inlinable
    public func decoration(from: CGPoint, to: CGPoint) -> Path? { nil }
}

public protocol StraightLineLinkShape: LinkShape { }

extension LinkShape where Self: StraightLineLinkShape {
    @inlinable
    public func path(from: CGPoint, to: CGPoint) -> Path {
        Path { path in
            path.move(to: from)
            path.addLine(to: to)
        }
    }
}

public struct PlainLineLink: LinkShape, StraightLineLinkShape { }

public struct ArrowLineLink: LinkShape {
    @usableFromInline
    let arrowSize: CGSize

    @usableFromInline
    let arrowAngle: CGFloat

    @usableFromInline
    let arrowCornerRadius: CGFloat

    @inlinable
    public func path(from: CGPoint, to: CGPoint) -> Path {
        Path {
            path in
            let angle = atan2(to.y - from.y, to.x - from.x)
            let arrowPoint = CGPoint(
                x: to.x - arrowSize.width * cos(angle),
                y: to.y - arrowSize.height * sin(angle)
            )
            path.move(to: from)
            path.addLine(to: arrowPoint)
            path.addLine(
                to: CGPoint(
                    x: arrowPoint.x - arrowSize.width * cos(angle + arrowAngle),
                    y: arrowPoint.y - arrowSize.height * sin(angle + arrowAngle)
                ))
            path.move(to: arrowPoint)
            path.addLine(
                to: CGPoint(
                    x: arrowPoint.x - arrowSize.width * cos(angle - arrowAngle),
                    y: arrowPoint.y - arrowSize.height * sin(angle - arrowAngle)
                ))
        }
    }
}
