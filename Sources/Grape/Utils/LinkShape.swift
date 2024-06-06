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

public protocol StraightLineLinkShape: LinkShape {}

extension LinkShape where Self: StraightLineLinkShape {
    @inlinable
    public func path(from: CGPoint, to: CGPoint) -> Path {
        Path { path in
            path.move(to: from)
            path.addLine(to: to)
        }
    }
}

public struct PlainLineLink: LinkShape, StraightLineLinkShape {
    @inlinable
    public init() {}
}

extension LinkShape where Self == ArrowLineLink {
    @inlinable
    public static func arrow(
        size: CGFloat = 10,
        angle: Angle = .degrees(32),
        cornerRadius: CGFloat = 0
    ) -> Self {
        .init(arrowSize: size, arrowAngle: angle, arrowCornerRadius: cornerRadius)
    }

    @inlinable
    public static var arrow: Self {
        arrow()
    }
}

public struct ArrowLineLink: LinkShape {
    @usableFromInline
    let arrowSize: CGFloat

    @usableFromInline
    let arrowAngle: Angle

    @usableFromInline
    let arrowCornerRadius: CGFloat

    @inlinable
    public init(arrowSize: CGFloat, arrowAngle: Angle, arrowCornerRadius: CGFloat) {
        self.arrowSize = arrowSize
        self.arrowAngle = arrowAngle
        self.arrowCornerRadius = arrowCornerRadius
    }

    @inlinable
    public func path(from: CGPoint, to: CGPoint) -> Path {
        let arrowAngle = self.arrowAngle.radians
        return Path {
            path in
            let angle = atan2(to.y - from.y, to.x - from.x)
            let angleLeft = angle + arrowAngle
            let angleRight = angle - arrowAngle

            path.move(to: from)
            path.addLine(to: to)

            path.move(
                to: CGPoint(
                    x: to.x - arrowSize * cos(angleLeft),
                    y: to.y - arrowSize * sin(angleLeft)
                ))
            path.addLine(to: to)
            path.addLine(
                to: CGPoint(
                    x: to.x - arrowSize * cos(angleRight),
                    y: to.y - arrowSize * sin(angleRight)
                )
            )
        }
    }
}
