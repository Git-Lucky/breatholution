import UIKit

class InfiniteBreathingView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var breathingImageView: UIImageView!
    
    var dateFormatter = DateFormatter()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("InfiniteBreathingView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        backgroundColor = .clear
        
        breathingImageView.alpha = 0.75
    }
}
