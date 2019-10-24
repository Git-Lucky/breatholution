import UIKit

class BreathAnimator {
    
    private let displayLink: DisplayLink
    private var breathingView: UIView?
    private var startTime = CACurrentMediaTime()
    
    private let breathSessionTime = 60.0 //seconds
    
    private let minScale: Double
    private let maxScale: Double
    private var scaleRange: Double {
        return maxScale - minScale
    }
    
    private let inBreathTime = 4.0 //seconds
    private let outBreathTime = 6.0 //seconds
    private var totalTime: Double {
        return inBreathTime + outBreathTime
    }
    
    init(minScale: Double, maxScale: Double = 1.0) {
        self.minScale = minScale
        self.maxScale = maxScale
        self.displayLink = DisplayLink()
    }
    
    func makeBreathe(view: UIView) {
        breathingView = view
        startTime = CACurrentMediaTime()
        displayLink.startUpdates(delegate: self)
    }
    
    private func calculateScaleMultiplierForTime(_ time: TimeInterval) -> CGFloat {
        let loopTime = time.truncatingRemainder(dividingBy: totalTime)
        let breathingIn = 0...inBreathTime ~= loopTime
        if breathingIn {
            let percentComplete = easeInOut(loopTime / inBreathTime)
            let movement = percentComplete * scaleRange
            return CGFloat(movement + minScale)
        } else {
            let percentComplete = easeInOut((loopTime - inBreathTime) / outBreathTime)
            let movement = percentComplete * scaleRange
            return CGFloat(maxScale - movement)
        }
    }
    
    private func easeInOut(_ x: Double) -> Double {
        if (x < 0.5) {
            return 2 * x * x
        } else {
            return (-2 * x * x) + (4 * x) - 1
        }
    }
}

extension BreathAnimator: DisplayLinkDelegate {
    func displayLinkDidUpdate(_ displayLink: CADisplayLink) {
        let elapsedTime = CACurrentMediaTime() - startTime
        guard elapsedTime < breathSessionTime else {
            self.displayLink.stopUpdates()
            return
        }
        let updatedScale = calculateScaleMultiplierForTime(elapsedTime)
        breathingView?.transform = CGAffineTransform(scaleX: updatedScale, y: updatedScale)
    }
}
