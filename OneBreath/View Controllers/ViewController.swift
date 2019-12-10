import UIKit
import CountdownLabel

class ViewController: UIViewController {
    
    @IBOutlet weak var postBreathingView: PostBreathingView!
    @IBOutlet weak var breathingInLabel: UILabel!
    @IBOutlet weak var countdownView: UIView!
    @IBOutlet weak var breathVisualizationBoundingView: BreathVisualizationView! //for layout purposes
    @IBOutlet weak var instructionsLabel: UILabel!
    var animator: AnimatorOrchestrator?
    private let globeViewController = GlobeViewController()
    private var breathView = UIView()
    private var breathVisualizationViewInitialFrame: CGRect?
    private var progressView = ProgressView()
    private var faderView = UIImageView()
    
    var countdownLabel: CountdownLabel?
    
    var breatheDate: Date?
    
    //remove after poc
    @IBOutlet weak var beginBreathingButton: UIButton!
    //////////////
    let hapticGenerator = HapticGenerator()
    @IBAction func doHaptic(_ sender: Any) {
        hapticGenerator.breathIn()
    }
    //////////////
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        animator = AnimatorOrchestrator(delegate: self)
        
        view.addSubview(breathView)
                
        countdownLabel = CountdownLabel(frame: countdownView.bounds)
        countdownLabel?.font = .systemFont(ofSize: 23.0)
        countdownView.addSubview(countdownLabel!)
        
        self.breathingInLabel.alpha = 0
        self.countdownView.alpha = 0
        self.breathVisualizationBoundingView.alpha = 0
        self.postBreathingView.alpha = 0
        self.instructionsLabel.alpha = 0
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
        
        faderView = UIImageView(image: #imageLiteral(resourceName: "radialAlphaGradient"))
        faderView.frame = progressView.bounds
        faderView.transform = CGAffineTransform(scaleX: 1.005, y: 1.005)
        
        globeViewController.view.frame = breathView.bounds
        addChild(globeViewController)
        globeViewController.didMove(toParent: self)
        
        progressView.addSubview(faderView)
        breathView.addSubview(progressView)
        breathView.addSubview(globeViewController.view)
        
//        progressView.start(60)
                
        setupBaseViewState()
    }
    
    private func setupBaseViewState() {
        self.breathingInLabel.alpha = 0
        self.breathingInLabel.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        self.countdownView.alpha = 0
        self.countdownView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        self.faderView.alpha = 1
        
        UIView.animate(withDuration: 2.0, animations: {
            self.breathView.transform = .identity
            self.breathView.frame = self.breathVisualizationViewInitialFrame!
            self.instructionsLabel.alpha = 0
            self.postBreathingView.alpha = 0
        })
        
        UIView.animate(withDuration: 0.5) {
            self.breathingInLabel.transform = .identity
            self.breathingInLabel.alpha = 1
        }
        UIView.animate(withDuration: 0.5, delay: 0.25, animations: {
            self.countdownView.transform = .identity
            self.countdownView.alpha = 1
        })
        UIView.animate(withDuration: 1, delay: 0.75, animations: {
            self.breathView.alpha = 1
        })
        
        refreshBreathCountdown()
    }
    
    @objc func updateBreatheDate(_ notification: Notification) {
        print("breath date set notification received")
        breatheDate = notification.userInfo?["breatheDate"] as? Date
        refreshBreathCountdown()
    }
    
    func refreshBreathCountdown() {
        if let date = self.breatheDate {
            print("refreshing breath countdown")
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
    }
    
    func didBeginMainBreathingSequence(duration: TimeInterval) {
        progressView.start(duration)
    }
    
    func didBeginSilencePeriod() {
        globeViewController.setAutoRotateInterval(0, degrees: 1)
    }
    
    func didEndBreathing() {
        self.progressView.endAnimation {
            self.faderView.alpha = 0
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

extension ViewController {
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
}

