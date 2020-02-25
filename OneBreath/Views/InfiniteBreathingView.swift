import UIKit

class InfiniteBreathingView: UIView {
    
    @IBOutlet var contentView: UIView!
    var breathingImageView: UIImageView?
    var breathingStrokeImageView: UIImageView?
        
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
        
        let breathingImage = UIImage(named: "icon_O")
        breathingImageView = UIImageView(image: breathingImage)
        contentView.addSubview(breathingImageView!)
        breathingImageView?.alpha = 0.64
        let breathingStrokeImage = UIImage(named: "icon_O_Stroke")
        breathingStrokeImageView = UIImageView(image: breathingStrokeImage)
        breathingStrokeImageView?.alpha = 0.8
        contentView.addSubview(breathingStrokeImageView!)
        
        contentView.autoresizesSubviews = true
    }
    
    override func layoutSubviews() {
        breathingImageView?.frame = bounds
        breathingStrokeImageView?.frame = bounds
    }
}
