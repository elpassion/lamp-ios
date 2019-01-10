import UIKit

/**
 Delegate to the ColorWheel.
 */
public protocol ColorWheelDelegate: class {
    /**
     If a delegate is set, this method is invoked with the color closed to the
     user's tap location.
     */
    func didSelect(color: UIColor)
    func didRotate()
}

/**
 Basic color wheel picker.
 This class draws a round, wheel-like color picker which can be tapped by the user.
 The interpolated color closed to the tap location is returned to its `ColorWheelDelegate`.
 */
public class ColorWheel: UIView {
    /// Delegate to inform when color is picked.
    public weak var delegate: ColorWheelDelegate?

    /// Overall color brightness. Animatable.
    @objc public dynamic var brightness: CGFloat { didSet { wheelLayer.brightness = brightness } }

    /// Extra padding in points to the view border.
    public var padding: CGFloat = 12.0 { didSet { setNeedsDisplay() } }

    /// Radius in point of the central color circle (for black & white shades).
    public var centerRadius: CGFloat = 4.0 { didSet { setNeedsDisplay() } }

    /// Smallest circle radius in point.
    public var minCircleRadius: CGFloat = 1.0 { didSet { setNeedsDisplay() } }

    /// Largest circle radius in point.
    public var maxCircleRadius: CGFloat = 6.0 { didSet { setNeedsDisplay() } }

    /// Padding between circles in point.
    public var innerPadding: CGFloat = 2 { didSet { setNeedsDisplay() } }

    /// Outer Radius of the ColorWheel in point.
    public var radius: CGFloat {
        return wheelLayer.radius(in: bounds)
    }

    /**
     Degree by which each row of circles is shifted.
     A value of 0 results in a straight layout of the inner circles.
     A value other than 0 results in a slightly shifted, fractal-ish / flower-ish look.
     */
    public var shiftDegree: CGFloat = 40 { didSet { setNeedsDisplay() } }

    /// Overall density of inner circles.
    public var density: CGFloat = 0.8 { didSet { setNeedsDisplay() } }

    private let normalizedRadius: CGFloat = 1.0

    fileprivate var wheelLayer: ColorWheelLayer! {
        return layer as? ColorWheelLayer
    }

    private var tapRecognizer: UITapGestureRecognizer!

    public required init?(coder aDecoder: NSCoder) {
        brightness = 1.0
        super.init(coder: aDecoder)

        layer.contentsScale = UIScreen.main.scale
        prepareTapRecognizer()
        contentMode = .redraw
    }

    public override init(frame: CGRect) {
        brightness = 1.0
        super.init(frame: frame)

        layer.contentsScale = UIScreen.main.scale
        prepareTapRecognizer()
        contentMode = .redraw
    }

    override public class var layerClass: AnyClass {
        return ColorWheelLayer.self
    }

    // taken from: https://stackoverflow.com/questions/14192816/create-a-custom-animatable-property/44961463#44961463
    // backgroundColor is simply a "placeholder" to get the UIView.animate() properties
    override public func action(for layer: CALayer, forKey event: String) -> CAAction? {
        if event == #keyPath(ColorWheelLayer.brightness),
            let action = action(for: layer, forKey: #keyPath(backgroundColor)) as? CAAnimation {

            let animation = CABasicAnimation()
            animation.keyPath = #keyPath(ColorWheelLayer.brightness)
            animation.fromValue = wheelLayer.brightness
            animation.toValue = brightness
            animation.beginTime = action.beginTime
            animation.duration = action.duration
            animation.speed = action.speed
            animation.timeOffset = action.timeOffset
            animation.repeatCount = action.repeatCount
            animation.repeatDuration = action.repeatDuration
            animation.autoreverses = action.autoreverses
            animation.fillMode = action.fillMode
            animation.timingFunction = action.timingFunction
            animation.delegate = action.delegate
            self.layer.add(animation, forKey: #keyPath(ColorWheelLayer.brightness))
        }
        return super.action(for: layer, forKey: event)
    }

    /**
     Distance from given point to center, normalized to the ColorWheel radius.
     0: directly on center
     1: directly on radius
     `to` is assumed to be in ColorWheel coordinates.
     */
    public func normalizedDistanceFromCenter(to touchPoint: CGPoint) -> CGFloat {
        let distance = sqrt(pow(touchPoint.x - wheelCenter.x, 2) + pow(touchPoint.y - wheelCenter.y, 2))
        return distance / radius
    }

    @objc func didRegisterTap(recognizer: UITapGestureRecognizer) {
        let touchPoint = recognizer.location(in: self)
        let distance = normalizedDistanceFromCenter(to: touchPoint)
        guard distance <= normalizedRadius else { return }

        let angle = adjustedAngleTo(center: wheelCenter, pointOnCircle: touchPoint, distance: distance)
        let tappedColor = wheelLayer.color(at: angle, distance: distance)
        delegate?.didSelect(color: tappedColor)
    }

    func angleTo(center: CGPoint, pointOnCircle: CGPoint) -> CGFloat {
        let originX = pointOnCircle.x - center.x
        let originY = pointOnCircle.y - center.y
        return atan2(originY, originX)
    }

    func adjustedAngleTo(center: CGPoint, pointOnCircle: CGPoint, distance: CGFloat) -> CGFloat {
        var radians = angleTo(center: center, pointOnCircle: pointOnCircle)
        while radians < 0 { radians += CGFloat(2 * Double.pi) }
        let counterClockwise = 2 * .pi - (radians + (shiftDegree * distance) / 180 * .pi)
        return counterClockwise
    }

    var wheelCenter: CGPoint {
        return CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2)
    }

    func prepareTapRecognizer() {
        tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.numberOfTouchesRequired = 1
        addGestureRecognizer(tapRecognizer)
        tapRecognizer.addTarget(self, action: #selector(didRegisterTap(recognizer:)))
    }
}

class ColorWheelLayer: CALayer {
    @NSManaged var brightness: CGFloat

    // swiftlint:disable force_cast
    private var padding: CGFloat { return (delegate as! ColorWheel).padding }
    private var centerRadius: CGFloat { return (delegate as! ColorWheel).centerRadius }
    private var minCircleRadius: CGFloat { return (delegate as! ColorWheel).minCircleRadius }
    private var maxCircleRadius: CGFloat { return (delegate as! ColorWheel).maxCircleRadius }
    private var innerPadding: CGFloat { return (delegate as! ColorWheel).innerPadding }
    private var shiftDegree: CGFloat { return (delegate as! ColorWheel).shiftDegree }
    private var density: CGFloat { return (delegate as! ColorWheel).density }
    // swiftlint:enable force_cast

    private let defaultBrightness: CGFloat = 1.0

    override init(layer: Any) {
        super.init(layer: layer)
        brightness = (layer as? ColorWheelLayer)?.brightness ?? 1.0
    }

    override init() {
        super.init()
        brightness = defaultBrightness
    }

    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)!
    }

    override class func needsDisplay(forKey key: String) -> Bool {
        if key == #keyPath(brightness) {
            return true
        }
        return super.needsDisplay(forKey: key)
    }

    override func draw(in context: CGContext) {
        super.draw(in: context)
        UIGraphicsPushContext(context)

        let outerRadius = radius(in: bounds)
        var innerRadius = outerRadius
        var prevDotRadius = dotRadius(distance: 1)
        var currentDotRadius: CGFloat
        let center = CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2)

        repeat {
            let distance = innerRadius / outerRadius
            currentDotRadius = dotRadius(distance: distance)

            arcPositions(dotRadius: currentDotRadius, on: innerRadius).forEach { rad in
                drawCircle(around: center, on: outerRadius, of: context, rad: rad, distance: distance)
            }
            innerRadius -= (prevDotRadius + 2 * currentDotRadius + innerPadding)
            prevDotRadius = currentDotRadius
        } while innerRadius > 2 * centerRadius + currentDotRadius

        drawCircle(around: center, on: outerRadius, of: context, rad: 0, distance: 0)
        UIGraphicsPopContext()
    }

    func radius(in rect: CGRect) -> CGFloat {
        return min(rect.size.width, rect.size.height) / 2 - padding
    }

    func color(at rad: CGFloat, distance: CGFloat) -> UIColor {
        return UIColor(hue: rad / (2 * .pi), saturation: distance, brightness: brightness, alpha: 1)
    }
}

fileprivate extension ColorWheelLayer {
    func arcPositions(dotRadius: CGFloat, on radius: CGFloat) -> [CGFloat] {
        let circlesFitting = (2 * dotRadius) > radius
            ? 1
            : max(1, Int((density * .pi / (asin((2 * dotRadius) / radius)))))
        let stepSize = 2 * .pi / CGFloat(circlesFitting - 1)
        return (0..<circlesFitting).map { CGFloat($0) * stepSize }
    }

    func drawCircle(around center: CGPoint, on outerRadius: CGFloat, of context: CGContext, rad: CGFloat, distance: CGFloat) {
        let circleRadius = dotRadius(distance: distance)
        let center = position(around: center, on: outerRadius, rad: rad, distance: distance)
        let circleColor = color(at: rad, distance: distance)
        let circleRect = CGRect(x: center.x - circleRadius,
                                y: center.y - circleRadius,
                                width: circleRadius * 2,
                                height: circleRadius * 2)
        context.setLineWidth(circleRadius)
        context.setStrokeColor(circleColor.cgColor)
        context.setFillColor(circleColor.cgColor)
        context.addEllipse(in: circleRect)
        context.drawPath(using: .fillStroke)
    }

    func dotRadius(distance: CGFloat) -> CGFloat {
        guard distance > 0 else { return centerRadius }
        return max(minCircleRadius, maxCircleRadius * distance)
    }

    func position(around center: CGPoint, on radius: CGFloat, rad: CGFloat, distance: CGFloat) -> CGPoint {
        let shiftedRad = rad + (shiftDegree * distance) / 180 * .pi
        let x = center.x + (radius - padding) * distance * cos(-shiftedRad)
        let y = center.y + (radius - padding) * distance * sin(-shiftedRad)
        return CGPoint(x: x, y: y)
    }
}

import Foundation
import UIKit

class DefaultWheelGestureHandler: NSObject, UIGestureRecognizerDelegate {
    weak var colorWheel: RotatingColorWheel?

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let colorWheel = colorWheel else { return false }

        switch gestureRecognizer {
        case colorWheel.panRecognizer: return handlePanGesture(colorWheel.panRecognizer)
        case colorWheel.rotateRecognizer: return handleRotateGesture(colorWheel.rotateRecognizer)
        default: return true // any other recognizer should deal with animation etc. itself
        }
    }

    private func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) -> Bool {
        guard let colorWheel = colorWheel else { return true }

        // since the view is rotated, the coordinates are also "rotated"
        let rotatedTouchPoint = gestureRecognizer.location(in: colorWheel)
        let distance = colorWheel.normalizedDistanceFromCenter(to: rotatedTouchPoint)
        let isWithinRadius = distance <= 1.0

        return isWithinRadius && !colorWheel.isAnimating
    }

    private func handleRotateGesture(_ gestureRecognizer: UIRotationGestureRecognizer) -> Bool {
        guard let colorWheel = colorWheel else { return true }

        // since the view is rotated, the coordinates are also "rotated"
        let rotatedTouchPointA = gestureRecognizer.location(ofTouch: 0, in: colorWheel)
        let rotatedTouchPointB = gestureRecognizer.location(ofTouch: 1, in: colorWheel)
        let distanceA = colorWheel.normalizedDistanceFromCenter(to: rotatedTouchPointA)
        let distanceB = colorWheel.normalizedDistanceFromCenter(to: rotatedTouchPointB)
        let areWithinRadius = distanceA <= 1.0 && distanceB <= 1.0

        return areWithinRadius && !colorWheel.isAnimating
    }
}

enum RotationDirection: CGFloat {
    case none = 0
    case clockwise = 1
    case counterClockwise = -1
}

/**
 Rotatable color wheel picker.
 This is a subclass of `ColorWheel`. It adds two `UIGestureRecognizeras` to itself.
 Those allow one-finger and two-finger circular rotation to adjust the overall
 brightness of the colors.
 */
public class RotatingColorWheel: ColorWheel, CAAnimationDelegate {
    public private(set) var panRecognizer: UIPanGestureRecognizer!
    public private(set) var rotateRecognizer: UIRotationGestureRecognizer!

    private let defaultGestureHandler: DefaultWheelGestureHandler

    private var rotationArch: CGFloat = 2 * .pi
    private var lastDirection: RotationDirection = .none
    private var lastAngle: CGFloat = 2 * .pi
    private var angleDeltas: [CGFloat] = [0, 0, 0]
    private var timeDeltas: [TimeInterval] = [0, 0, 0]
    private let maxRotationSpeed: CGFloat = 0.7
    private let minimumSpeedThreshold: CGFloat = 0.06
    private let rotationAnimationDuration = 0.5

    public required init?(coder aDecoder: NSCoder) {
        defaultGestureHandler = DefaultWheelGestureHandler()
        super.init(coder: aDecoder)
        prepareRotationRecognizers()
    }

    public override init(frame: CGRect) {
        defaultGestureHandler = DefaultWheelGestureHandler()
        super.init(frame: frame)
        prepareRotationRecognizers()
    }

    public var isAnimating: Bool {
        return layer.animationKeys()?.isEmpty ?? false
    }

    @objc func didRotate(recognizer: UIRotationGestureRecognizer) {
        let newRotationArch = rotationArch + recognizer.rotation
        if recognizer.state == .changed {
            rotate(to: dampened(rotation: newRotationArch))
        } else if recognizer.state == .ended {
            rotationArch = newRotationArch
            continueAnimationMotionOrSnapBackIfOutOfRange(velocity: recognizer.velocity)
        } else if recognizer.state == .cancelled {
            continueAnimationMotionOrSnapBackIfOutOfRange(velocity: recognizer.velocity)
        }
    }

    func angleDelta(_ newAngle: CGFloat, _ oldAngle: CGFloat) -> CGFloat {
        return abs((abs(newAngle) - abs(oldAngle))) * movementDirection(newAngle, oldAngle).rawValue
    }

    func movementDirection(_ newAngle: CGFloat, _ oldAngle: CGFloat) -> RotationDirection {
        if newAngle < 0 && oldAngle > 0 && abs(newAngle) > .pi / 2 {
            return .clockwise
        } else if newAngle > 0 && oldAngle < 0 && abs(newAngle) > .pi / 2 {
            return .counterClockwise
        } else if newAngle > oldAngle {
            return .clockwise
        } else {
            return .counterClockwise
        }
    }

    func dampened(rotation: CGFloat) -> CGFloat {
        if rotation < 0 {
            let minValue: CGFloat = -(.pi)
            let undampenedDelta = max(minValue, rotation)
            let progress = abs(undampenedDelta / .pi)
            let dampenedProgress = sin(sqrt(progress) * (.pi / 2))
            return dampenedProgress * (-(.pi / 8))
        } else if rotation > 2 * .pi {
            let maxValue: CGFloat = 2 * .pi + .pi
            let undampenedDelta = min(maxValue, rotation) - 2 * .pi
            let progress = undampenedDelta / .pi
            let dampenedProgress = sin(sqrt(progress) * (.pi / 2))
            return 2 * .pi + dampenedProgress * (.pi / 8)
        }
        return rotation
    }

    @objc func didPan(recognizer: UIPanGestureRecognizer) {
        let touchPoint = recognizer.location(in: superview!)
        let center = convert(wheelCenter, to: superview!)
        let angle = angleTo(center: center, pointOnCircle: touchPoint)

        let newRotationArch = rotationArch + angleDelta(angle, lastAngle)
        trackAngleTravelled(delta: angleDelta(angle, lastAngle))
        if recognizer.state == .began {
            angleDeltas = [0, 0, 0]
            timeDeltas = [0, 0, 0]
            lastAngle = angle
        } else if recognizer.state == .changed {
            rotate(to: dampened(rotation: newRotationArch))
            lastDirection = movementDirection(angle, lastAngle)
            lastAngle = angle
            rotationArch = newRotationArch
        } else if recognizer.state == .ended {
            rotationArch = newRotationArch
            continueAnimationMotionOrSnapBackIfOutOfRange(velocity: radialSpeed(direction: lastDirection))
        } else if recognizer.state == .cancelled {
            continueAnimationMotionOrSnapBackIfOutOfRange(velocity: radialSpeed(direction: lastDirection))
        }
    }

    func trackAngleTravelled(delta: CGFloat) {
        angleDeltas.append(abs(delta))
        timeDeltas.append(Date().timeIntervalSince1970)
        angleDeltas.remove(at: 0)
        timeDeltas.remove(at: 0)
    }

    func radialSpeed(direction: RotationDirection) -> CGFloat {
        let distance: CGFloat = abs(angleDeltas.reduce(0, +))
        let timeDelta: CGFloat = CGFloat(timeDeltas.last! - timeDeltas.first!) * 10
        return min(maxRotationSpeed, distance / timeDelta) * direction.rawValue
    }

    func isOutOfSpinRange() -> Bool {
        return rotationArch < 0 || rotationArch > 2 * .pi
    }

    func continueAnimationMotionOrSnapBackIfOutOfRange(velocity: CGFloat) {
        if isOutOfSpinRange() {
            animateSpinBackMotion()
        } else if abs(velocity) > minimumSpeedThreshold {
            let deceleration: CGFloat = 0.1 // rad/s^2
            var distance = pow(velocity, 2) / (2 * deceleration)
            while distance >= .pi { distance -= .pi / 8 }
            let targetRotationArch = min(2 * .pi, max(0, rotationArch + distance * (velocity > 0 ? 1 : -1)))
            let targetRotationTransform = CATransform3DRotate(CATransform3DIdentity, targetRotationArch, 0, 0, 1)
            let targetBrightness = targetRotationArch / (2 * .pi)

            UIView.animate(withDuration: rotationAnimationDuration, delay: 0, options: .curveEaseOut, animations: {
                self.brightness = targetBrightness
                self.layer.transform = targetRotationTransform
            })

            brightness = targetBrightness
            rotationArch = targetRotationArch
        }
    }

    private func prepareRotationRecognizers() {
        defaultGestureHandler.colorWheel = self
        rotateRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(didRotate(recognizer:)))
        panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPan(recognizer:)))
        rotateRecognizer.delegate = defaultGestureHandler
        panRecognizer.delegate = defaultGestureHandler
        addGestureRecognizer(rotateRecognizer)
        addGestureRecognizer(panRecognizer)
    }
}

// MARK: - CAAnimationDelegate

extension RotatingColorWheel {
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if isOutOfSpinRange() {
            animateSpinBackMotion()
        }
    }
}

// MARK: - Private

fileprivate extension RotatingColorWheel {
    func animateSpinBackMotion() {
        let targetRotationArch: CGFloat = rotationArch < 0 ? 0 : 2 * .pi
        let spring = CASpringAnimation(keyPath: "transform")
        spring.damping = 20
        spring.stiffness = 1000
        spring.fromValue = NSValue(caTransform3D: layer.transform)
        // probably CATransform3DIdentity is enough here, but does it result in the same layer.transform?
        spring.toValue = NSValue(caTransform3D: CATransform3DRotate(CATransform3DIdentity, targetRotationArch, 0, 0, 1))
        spring.duration = spring.settlingDuration
        layer.transform = CATransform3DRotate(CATransform3DIdentity, targetRotationArch, 0, 0, 1)
        layer.add(spring, forKey: "transformAnimation")
        rotationArch = targetRotationArch
        brightness = targetRotationArch / (2 * .pi)
    }

    func rotate(to radians: CGFloat) {
        transform = CGAffineTransform(rotationAngle: radians)
        let mappedBrightness = radians / (2 * .pi)
        guard mappedBrightness >= 0 && mappedBrightness <= 1.0 else { return }
        brightness = mappedBrightness
        delegate?.didRotate()
    }
}
