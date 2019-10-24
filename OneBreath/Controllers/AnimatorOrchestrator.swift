import UIKit

class AnimatorOrchestrator {

    private let minScale = 0.4
    
    private let breathAnimator: BreathAnimator
    
    init() {
        self.breathAnimator = BreathAnimator(minScale: minScale)
    }
    
    func beginBreathingAnimationSequence(view: UIView) {
        IntroAnimator.animateIntro(view: view, duration: 2, scale: CGFloat(minScale)) {
            self.breathAnimator.makeBreathe(view: view)
        }
    }
}
