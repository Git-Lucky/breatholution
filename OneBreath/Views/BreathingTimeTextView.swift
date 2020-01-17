import UIKit

class BreathingTimeTextView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var label: UILabel!
    
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
        Bundle.main.loadNibNamed("BreathingTimeTextView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        label.font = UIFont(name: "CocogoosePro-Light", size: 16.0)
        self.backgroundColor = .clear
        
        dateFormatter.dateFormat = "h:mma"
//        dateFormatter.amSymbol = "AM"
//        dateFormatter.pmSymbol = "PM"
    }
    
    func setTimeText(_ date: Date) {
        let breatheTimeString = dateFormatter.string(from: date)
        label.text = "NEXT GLOBAL BREATHING @ \(breatheTimeString)"
    }
}

//private func showCountdown() {
//    if let date = breatheDate {
//        refreshBreathCountdown()
        
//        UIView.animate(withDuration: 0.5) {
//            self.breathingInLabel.transform = .identity
//            self.breathingInLabel.alpha = 1
//        }
//        UIView.animate(withDuration: 0.5, delay: 0.25, animations: {
//            self.countdownView.transform = .identity
//            self.countdownView.alpha = 1
//        })
//    }
//}
