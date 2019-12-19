import UIKit

class IntroAnimator {
    
    static func animateIntro(view: UIView, duration: TimeInterval, scale: CGFloat) {
        UIView.animate(withDuration: duration, animations: {
            view.transform = CGAffineTransform(scaleX: scale, y: scale)
        })
    }
    
}
