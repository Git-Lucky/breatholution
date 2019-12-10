import Foundation
import UICircularProgressRing

class ProgressView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var timerRing: UICircularTimerRing!
    @IBOutlet weak var eraserTimerRing: UICircularTimerRing!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("ProgressView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        self.backgroundColor = .clear
        
        self.timerRing.style = .ontop
        self.timerRing.outerRingColor = .clear
        self.timerRing.outerRingWidth = 1
        self.timerRing.innerRingColor = .label
        self.timerRing.innerRingWidth = 7
        self.timerRing.startAngle = 92
        
        self.eraserTimerRing.style = self.timerRing.style
        self.eraserTimerRing.outerRingColor = self.timerRing.outerRingColor
        self.eraserTimerRing.outerRingWidth = self.timerRing.outerRingWidth
        self.eraserTimerRing.innerRingColor = .systemBackground
        self.eraserTimerRing.innerRingWidth = self.timerRing.innerRingWidth
        self.eraserTimerRing.startAngle = self.timerRing.startAngle
        
        self.timerRing.alpha = 0
        self.eraserTimerRing.alpha = 0
    }
    
    func start(_ duration: TimeInterval) {
        UIView.animate(withDuration: 0.5) {
            self.timerRing.alpha = 1
        }
        timerRing.startTimer(to: duration) { state in
            switch state {
            case .finished:
                print("finished")
            case .continued(let time):
                print("continued: \(String(describing: time))")
            case .paused(let time):
                print("paused: \(String(describing: time))")
            }
        }
    }
    
    func endAnimation(_ completion: @escaping () -> Void) {
        self.eraserTimerRing.alpha = 1
        self.eraserTimerRing.startTimer(to: 1) { (state) in
            switch state {
            case .finished:
                print("finished")
                self.timerRing.alpha = 0
                self.eraserTimerRing.alpha = 0
                completion()
            case .continued(let time):
                print("continued: \(String(describing: time))")
            case .paused(let time):
                print("paused: \(String(describing: time))")
            }
        }
    }
}
