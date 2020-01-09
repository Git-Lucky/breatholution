import UIKit
import CountdownLabel

class ViewController: UIViewController {
    
    @IBOutlet weak var postBreathingView: PostBreathingView!
    @IBOutlet weak var breathingInLabel: UILabel!
    @IBOutlet weak var countdownView: UIView!
    @IBOutlet weak var breathVisualizationBoundingView: BreathVisualizationView! //for layout purposes
    @IBOutlet weak var infoTextView: UITextView!
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var broadcastPlayer: BambuserPlayerView!
    @IBOutlet weak var broadcastGlobePositionView: UIView!
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
        
        self.breathingInLabel.alpha = 0
        self.breathingInLabel.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        self.countdownView.alpha = 0
        self.countdownView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        self.infoTextView.alpha = 0
        var downShiftedFrame = self.infoTextView.frame
        downShiftedFrame.origin.y += 40
        self.infoTextView.frame = downShiftedFrame
        
        self.setupBaseViewState()
        
        Networker.checkForLiveBroadcast { (broadcast) in
            guard let cast = broadcast else { return }
            self.broadcastIsLive(cast)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateBreatheDate(_:)), name: NSNotification.Name(rawValue: "breatheDateSet"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(broadcastStartedNotification(_:)), name: NSNotification.Name(rawValue: "broadcastStarted"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appBecameActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    private func setupBaseViewState() {
        // Hide irrelevant views
        hidePostBreathingAndInstructionsViews()
        showBreathView()
        // Show the countdown
        DispatchQueue.main.asyncAfter(deadline: .now()+0.8) {
            self.showCountdown()
        }
    }
    
    func setupLiveBroadcastState() {
        hideCountdownLabels()
        hidePostBreathingAndInstructionsViews()
        showBreathView()
        UIView.animate(withDuration: 2.0, delay: 0, options: .curveEaseInOut, animations: {
            self.breathView.frame = self.broadcastGlobePositionView.frame
        })
    }
    
    func setupPostBreathingView() {
        hideCountdownLabels()
        let convertedFrame = self.postBreathingView.globeView.convert(self.postBreathingView.globeView.bounds, to: self.view)
        UIView.animate(withDuration: 2.0, animations: {
            self.postBreathingView.alpha = 1
        })
        UIView.animate(withDuration: 2.0, delay: 0.33, options: .curveEaseInOut, animations: {
            self.breathView.frame = convertedFrame
        })
    }
    
    func showBreathView() {
        // Move globe back to its original size and place
        UIView.animate(withDuration: 2.0, delay: 0, options: .curveEaseInOut, animations: {
            self.breathView.transform = .identity
            self.breathView.frame = self.breathVisualizationViewInitialFrame!
        })
        // show the globe if it was hidden... a delay because it takes some time to load the first time
        UIView.animate(withDuration: 1, delay: 0.75, options: [], animations: {
            self.breathView.alpha = 1
        })
    }
    
    @objc func updateBreatheDate(_ notification: Notification) {
        breatheDate = notification.userInfo?["breatheDate"] as? Date
        refreshBreathCountdown()
    }
    
    func refreshBreathCountdown() {
        if let date = self.breatheDate {
            countdownLabel?.setCountDownDate(targetDate: date as NSDate)
            countdownLabel?.start()
            animator?.beginBreathingSequence(breathView: breathView, onDate: date, instructionsLabel: instructionsLabel)
        }
    }
    
    func showCountdown() {
        if let date = breatheDate {
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
        }
    }
    
    func hidePostBreathingAndInstructionsViews() {
        UIView.animate(withDuration: 0.5, delay: 0, animations: {
            self.instructionsLabel.alpha = 0
            self.postBreathingView.alpha = 0
        })
    }
    
    func hideCountdownLabels() {
            UIView.animate(withDuration: 0.5, delay: 0.25, animations: {
                self.countdownView.alpha = 0
                self.countdownView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            })
            UIView.animate(withDuration: 0.5, delay: 0.5, animations: {
                self.breathingInLabel.alpha = 0
                self.breathingInLabel.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            })
            
    //        var downShiftedFrame = self.infoTextView.frame
    //        downShiftedFrame.origin.y += 40
    //        UIView.animate(withDuration: 0.5, delay: 0, animations: {
    //            self.infoTextView.alpha = 0
    //            self.infoTextView.frame = downShiftedFrame
    //        })
        }
    
    @objc func broadcastStartedNotification(_ notification: Notification) {
        let broadcast = notification.userInfo?["broadcastDetails"] as! Broadcast
        print("Broadcast details received")
        print(broadcast)
        broadcastIsLive(broadcast)
    }
    
    @objc func appBecameActive(_ notification: Notification) {
        Networker.checkForLiveBroadcast { (broadcast) in
            guard let cast = broadcast else { return }
            self.broadcastIsLive(cast)
        }
    }
    
    func broadcastIsLive(_ broadcast: Broadcast) {
        setupLiveBroadcastState()
        broadcastPlayer.broadcastIsLive(broadcast, delegate: self)
    }
    
    func broadcastStopped() {
        setupPostBreathingView()
    }
    
    @IBAction func beginBreathingButton(_ sender: UIButton) {
        setupLiveBroadcastState()
    }
    
    @IBAction func resetButton(_ sender: Any) {
        setupBaseViewState()
    }
}

extension ViewController: BambuserPlayerViewDelegate {
    func didEndBroadcast() {
        broadcastStopped()
    }
    
    func didError() {
        Networker.checkForLiveBroadcast { (broadcast) in
            guard let cast = broadcast else {
                self.setupBaseViewState()
                return
            }
            self.broadcastIsLive(cast)
        }
     }
}

extension ViewController: AnimatorOrchestratorDelegate {
    func didBeginBreathingIntro() {
        hideCountdownLabels()
        instructionsLabel.text = "Welcome to the Breatholution!"
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
            self.setupPostBreathingView()
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
