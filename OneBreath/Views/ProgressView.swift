import Foundation
import UICircularProgressRing

class ProgressView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var timerRing: UICircularTimerRing!
    
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
        
        setupTimerRing()
    }
    
    func setupTimerRing() {
        timerRing.startTimer(to: 60) { state in
            switch state {
            case .finished:
                print("finished")
            case .continued(let time):
                print("continued: \(time)")
            case .paused(let time):
                print("paused: \(time)")
            }
        }
    }
}
