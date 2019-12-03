import UIKit
import CountdownLabel

class ViewController: UIViewController {
    
    @IBOutlet weak var postBreathingView: PostBreathingView!
    @IBOutlet weak var breathingInLabel: UILabel!
    @IBOutlet weak var countdownView: UIView!
    @IBOutlet weak var breathVisualizationView: BreathVisualizationView!
    @IBOutlet weak var instructionsLabel: UILabel!
    var animator: AnimatorOrchestrator?
    private let globeViewController = GlobeViewController()
    private var breathVisualizationViewInitialFrame: CGRect?
    
    var countdownLabel: CountdownLabel?
    
    //remove after poc
    @IBOutlet weak var beginBreathingButton: UIButton!
    @IBOutlet weak var resetButton: NSLayoutConstraint!
    
    //////////////
    let hapticGenerator = HapticGenerator()
    @IBAction func doHaptic(_ sender: Any) {
        hapticGenerator.breathIn()
    }
    //////////////
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        animator = AnimatorOrchestrator(delegate: self)
        
        breathVisualizationView.addSubview(globeViewController.view)
        globeViewController.view.frame = breathVisualizationView.bounds
        addChild(globeViewController)
        globeViewController.didMove(toParent: self)
                
        countdownLabel = CountdownLabel(frame: countdownView.bounds)
        countdownLabel?.font = .systemFont(ofSize: 23.0)
        countdownView.addSubview(countdownLabel!)
        
        self.breathingInLabel.alpha = 0
        self.countdownView.alpha = 0
        self.breathVisualizationView.alpha = 0
        self.countdownView.backgroundColor = .clear
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        breathVisualizationViewInitialFrame = breathVisualizationView.frame
        
        setupBaseViewState()
    }
    
    private func setupBaseViewState() {
        self.breathingInLabel.alpha = 0
        self.breathingInLabel.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        self.countdownView.alpha = 0
        self.countdownView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        UIView.animate(withDuration: 2.0, animations: {
            self.breathVisualizationView.frame = self.breathVisualizationViewInitialFrame!
        }) { (_) in
            self.instructionsLabel.alpha = 0
            self.postBreathingView.alpha = 0
        }
        
        UIView.animate(withDuration: 0.5) {
            self.breathingInLabel.transform = .identity
            self.breathingInLabel.alpha = 1
        }
        UIView.animate(withDuration: 0.5, delay: 0.25, animations: {
            self.countdownView.transform = .identity
            self.countdownView.alpha = 1
        })
        UIView.animate(withDuration: 0.5, delay: 1.5, animations: {
            self.breathVisualizationView.alpha = 1
        })
        
        
        // pull this date from a server in the future
        let date = NSDate(timeIntervalSinceNow: 11111)
        countdownLabel?.setCountDownDate(targetDate: date)
        countdownLabel?.start()
        animator?.beginBreathingSequence(breathView: breathVisualizationView, onDate: date as Date, instructionsLabel: instructionsLabel)
    }
    
    @IBAction func beginBreathingButton(_ sender: UIButton) {
        let date = NSDate(timeIntervalSinceNow: 4)
        countdownLabel?.setCountDownDate(targetDate: date)
        countdownLabel?.start()
        animator?.beginBreathingSequence(breathView: breathVisualizationView, onDate: date as Date, instructionsLabel: instructionsLabel)
    }
    
    @IBAction func resetButton(_ sender: Any) {
//        let convertedFrame = postBreathingView.globeView.convert(postBreathingView.globeView.frame, to: view)
//        breathVisualizationView.frame = convertedFrame
//        setupBaseViewState()
        globeViewController.setAutoRotateInterval(0.01, degrees: 1)
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
    
    func didBeginSilencePeriod() {
        globeViewController.setAutoRotateInterval(0, degrees: 1)
    }
    
    func didEndBreathing() {
        let convertedFrame = postBreathingView.globeView.convert(postBreathingView.globeView.frame, to: view)
        UIView.animate(withDuration: 2.0, delay: 0.33, animations: {
            self.postBreathingView.alpha = 1
            self.breathVisualizationView.transform = .identity
            self.breathVisualizationView.frame = convertedFrame
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.postBreathingView.showBreathLabel()
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

