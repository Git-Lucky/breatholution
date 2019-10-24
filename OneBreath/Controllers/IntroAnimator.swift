import UIKit

class IntroAnimator {
    
    static func animateIntro(view: UIView, duration: TimeInterval, scale: CGFloat, completion: @escaping () -> Void) {
        UIView.animate(withDuration: duration, animations: {
            view.transform = CGAffineTransform(scaleX: scale, y: scale)
        }) { (success) in
            completion()
        }
    }
    
}
