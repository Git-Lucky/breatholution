import UIKit

class BreathAnimator {
    
    private let displayLink: DisplayLink
    private var breathingView: UIView?
    private var startTime = CACurrentMediaTime()
    private let fileManager = FileManager()
    
    private let numberOfBreathCycles: Int
    private var breathSessionTime: Double {
        return (inBreathTime + outBreathTime) * Double(numberOfBreathCycles)
    }
    
    private let minScale: Double
    private let maxScale: Double
    private var scaleRange: Double {
        return maxScale - minScale
    }
    
    private let inBreathTime: Double //seconds
    private let outBreathTime: Double //seconds
    private var totalTime: Double {
        return inBreathTime + outBreathTime
    }
    
    private var completion: (() -> Void)?
    
    init(minScale: Double, maxScale: Double = 1.0, numberOfBreathCycles: Int, inBreathDuration: Double, outBreathDuration: Double) {
        self.minScale = minScale
        self.maxScale = maxScale
        self.numberOfBreathCycles = numberOfBreathCycles
        self.inBreathTime = inBreathDuration
        self.outBreathTime = outBreathDuration
        self.displayLink = DisplayLink()
    }
    
    func makeBreathe(view: UIView, completion: @escaping () -> Void) {
        breathingView = view
        startTime = CACurrentMediaTime()
        displayLink.startUpdates(delegate: self)
        self.completion = completion
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
    
    private func animationComplete() {
        self.displayLink.stopUpdates()
        completion?()
    }
    
    private func scaleBreathingViewForElaspsedTime(_ elapsedTime: TimeInterval) {
        let updatedScale = calculateScaleMultiplierForTime(elapsedTime)
        breathingView?.transform = CGAffineTransform(scaleX: updatedScale, y: updatedScale)
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
            animationComplete()
            return
        }
        scaleBreathingViewForElaspsedTime(elapsedTime)
    }
}
