import UIKit
import CountdownLabel

class CountdownView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var countdownLabel: CountdownLabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("CountdownView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        self.backgroundColor = .clear
        
        countdownLabel.font = UIFont(name: "CocogoosePro-Light", size: 28.0)
        countdownLabel.textColor = .systemBackground
        countdownLabel.textAlignment = .center
        countdownLabel.backgroundColor = .clear
    }
    
    func setCountdownDate(_ date: Date) {
        // Check to see if the breatheDate is in the past
        var countdownDate = date
        if countdownDate < Date() {
            // Now set the date with the proper hour and minute of the breathe time
            let calendar = Calendar.current
            let previousDateComponents = calendar.dateComponents([.hour, .minute], from: countdownDate)
            let currentDateComponents = calendar.dateComponents([.hour, .minute, .day, .year], from: Date())
            var dateComponents = currentDateComponents
            dateComponents.hour = previousDateComponents.hour
            dateComponents.minute = previousDateComponents.minute
            dateComponents.second = 0
            countdownDate = calendar.date(from: dateComponents)!
            
            // compare to see if its already happened and if so push it up another day
            if countdownDate < Date() {
                countdownDate = countdownDate.addingTimeInterval(86400)
            }
        }
        countdownLabel?.setCountDownDate(targetDate: countdownDate as NSDate)
        countdownLabel?.start()
    }
}
