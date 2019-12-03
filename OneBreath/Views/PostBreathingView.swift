import UIKit

class PostBreathingView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var globeView: UIView!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var breathLabel: UILabel!
    @IBOutlet weak var oneBreathLabelConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("PostBreathingView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        self.backgroundColor = .clear
        self.globeView.backgroundColor = .clear
        
        bodyLabel.text = "Wow! That was awesome!\nThanks for breathing with us."
        
        breathLabel.alpha = 0.0
        breathLabel.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
    }
    
    func showBreathLabel() {
        self.oneBreathLabelConstraint.priority = .defaultHigh
        UIView.animate(withDuration: 1.33, animations: {
            self.layoutIfNeeded()
            self.breathLabel.alpha = 1.0
            self.breathLabel.transform = .identity
        })
    }
}
