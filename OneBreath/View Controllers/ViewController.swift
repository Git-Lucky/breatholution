import UIKit
import CountdownLabel

class ViewController: UIViewController {
    
    @IBOutlet weak var postBreathingView: PostBreathingView!
    @IBOutlet weak var breathingInLabel: UILabel!
    @IBOutlet weak var countdownView: UIView!
    @IBOutlet weak var breathVisualizationBoundingView: BreathVisualizationView! //for layout purposes
    @IBOutlet weak var infoTextView: UITextView!
    @IBOutlet weak var instructionsLabel: UILabel!
    var animator: AnimatorOrchestrator?
    private let globeViewController = GlobeViewController()
    private var breathView = UIView()
    private var breathVisualizationViewInitialFrame: CGRect?
    private var progressView = ProgressView()
    
    var countdownLabel: CountdownLabel?
    
    var breatheDate: Date?
    let dateFormatter = DateFormatter()
    
    let hapticGenerator = HapticGenerator()
    
    //remove after poc
    @IBOutlet weak var beginBreathingButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        animator = AnimatorOrchestrator(delegate: self)
    
        dateFormatter.dateFormat = "h:mma"
        dateFormatter.amSymbol = "am"
        dateFormatter.pmSymbol = "pm"
        
        infoTextView.text = "Breath science shows...\nbreathing exercises help one’s ability to experience repetitive thoughts and emotions without experiencing emotional distress because of them."
        
        view.addSubview(breathView)
                
        countdownLabel = CountdownLabel(frame: countdownView.bounds)
        countdownLabel?.font = .systemFont(ofSize: 23.0)
        countdownView.addSubview(countdownLabel!)
        
        self.breathingInLabel.alpha = 0
        self.countdownView.alpha = 0
        self.breathVisualizationBoundingView.alpha = 0
        self.postBreathingView.alpha = 0
        self.instructionsLabel.alpha = 0
        self.infoTextView.alpha = 0
        self.countdownView.backgroundColor = .clear
        self.breathView.alpha = 0
        
        self.breatheDate = UserDefaults.standard.value(forKey: "breatheDate") as? Date
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateBreatheDate), name: NSNotification.Name(rawValue: "breatheDateSet"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        breathVisualizationViewInitialFrame = breathVisualizationBoundingView.frame
        breathView.frame = breathVisualizationBoundingView.frame
        breathView.autoresizesSubviews = true
        
        progressView.frame = breathView.bounds
        progressView.transform = CGAffineTransform(scaleX: 1.07, y: 1.07)
        
        globeViewController.view.frame = breathView.bounds
        addChild(globeViewController)
        globeViewController.didMove(toParent: self)
        
        breathView.addSubview(progressView)
        breathView.addSubview(globeViewController.view)
                        
        setupBaseViewState()
    }
    
    private func setupBaseViewState() {
        //TODO: wrap these up in a method
        self.breathingInLabel.alpha = 0
        self.breathingInLabel.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        self.countdownView.alpha = 0
        self.countdownView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        self.infoTextView.alpha = 0
        ////////////////////
        
        UIView.animate(withDuration: 2.0, animations: {
            self.breathView.transform = .identity
            self.breathView.frame = self.breathVisualizationViewInitialFrame!
            self.instructionsLabel.alpha = 0
            self.postBreathingView.alpha = 0
        })
        
        if let breatheDate = breatheDate {
            let breatheTimeString = dateFormatter.string(from: breatheDate)
            breathingInLabel.text = "Breathe with the\nworld @ \(breatheTimeString)"
            UIView.animate(withDuration: 0.5) {
                self.breathingInLabel.transform = .identity
                self.breathingInLabel.alpha = 1
            }
            UIView.animate(withDuration: 0.5, delay: 0.25, animations: {
                self.countdownView.transform = .identity
                self.countdownView.alpha = 1
            })
        }
        
        UIView.animate(withDuration: 1, delay: 0.75, animations: {
            self.breathView.alpha = 1
            self.infoTextView.alpha = 1
            self.infoTextView.transform = .identity
        })
        
        refreshBreathCountdown()
    }
    
    @objc func updateBreatheDate(_ notification: Notification) {
        breatheDate = notification.userInfo?["breatheDate"] as? Date
        refreshBreathCountdown()
    }
    
    func refreshBreathCountdown() {
        if let date = self.breatheDate {
            // TODO: dry this out, its used above verbatim
            let breatheTimeString = dateFormatter.string(from: date)
            breathingInLabel.text = "Breathe with the world @ \(breatheTimeString)"
            UIView.animate(withDuration: 0.5) {
                self.breathingInLabel.transform = .identity
                self.breathingInLabel.alpha = 1
            }
            UIView.animate(withDuration: 0.5, delay: 0.25, animations: {
                self.countdownView.transform = .identity
                self.countdownView.alpha = 1
            })
            
            countdownLabel?.setCountDownDate(targetDate: date as NSDate)
            countdownLabel?.start()
            animator?.beginBreathingSequence(breathView: breathView, onDate: date, instructionsLabel: instructionsLabel)
        }
    }
    
    @IBAction func beginBreathingButton(_ sender: UIButton) {
        let date = NSDate(timeIntervalSinceNow: 4)
        countdownLabel?.setCountDownDate(targetDate: date)
        countdownLabel?.start()
        animator?.beginBreathingSequence(breathView: breathView, onDate: date as Date, instructionsLabel: instructionsLabel)
    }
    
    @IBAction func resetButton(_ sender: Any) {
        setupBaseViewState()
    }
}

extension ViewController: AnimatorOrchestratorDelegate {
    func didBeginBreathingIntro() {
        UIView.animate(withDuration: 0.5) {
            self.countdownView.alpha = 0
            self.countdownView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }
        UIView.animate(withDuration: 0.5, delay: 0.25, animations: {
            self.breathingInLabel.alpha = 0
            self.breathingInLabel.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        })
        UIView.animate(withDuration: 0.5, delay: 0.25, animations: {
            self.infoTextView.alpha = 0
            self.infoTextView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        })
        
        instructionsLabel.text = "Welcome to the Breatholution!"
//        audioManager?.beginWelcome()
    }
    
    func didBeginMainBreathingSequence(inBreathDuration: Double, outBreathDuration: Double, numberOfCycles: Int) {
        progressView.start((inBreathDuration+outBreathDuration)*Double(numberOfCycles))
        hapticGenerator.beginHapticBreathing(inBreathDuration: inBreathDuration, outBreathDuration: outBreathDuration, numCycles: numberOfCycles)
    }
    
    func didBeginSilencePeriod() {
        globeViewController.setAutoRotateInterval(0, degrees: 2)
    }
    
    func didEndBreathing() {
        self.progressView.endAnimation {
            let convertedFrame = self.postBreathingView.globeView.convert(self.postBreathingView.globeView.bounds, to: self.view)
            UIView.animate(withDuration: 2.0, animations: {
                self.postBreathingView.alpha = 1
            })
            UIView.animate(withDuration: 2.0, delay: 0.33, options: .curveEaseInOut, animations: {
                self.breathView.frame = convertedFrame
            })
        }
    }
}

extension ViewController: AudioManagerDelegate {
    func didFinishPlayingSegment(_ segment: AudioSegment) {
        switch segment {
        case .welcome:
            print("welcome ended")
            instructionsLabel.text = ""
        case .setIntention:
            print("still ended")
        case .still:
            instructionsLabel.text = "Be still and bring your\nattention to your breath"
            UIView.animate(withDuration: 0.5) {
                self.instructionsLabel.alpha = 1
            }
        }
    }
}

extension ViewController {
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
}
