import UIKit

class PostBreathingView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var globeView: UIView!
    @IBOutlet weak var bodyLabel: UILabel!
    
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
    }
}
