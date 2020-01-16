import UIKit
import CountdownLabel
import NVActivityIndicatorView

class ViewController: UIViewController {
    
    private let globeViewController = GlobeViewController()
    private var breathView = UIView()
    @IBOutlet weak var breathingInLabel: UILabel!
    @IBOutlet weak var countdownView: UIView!
    var countdownLabel: CountdownLabel?
    @IBOutlet weak var postBreathingView: PostBreathingView!
    @IBOutlet weak var breathVisualizationBoundingView: BreathVisualizationView! //for layout purposes
    @IBOutlet weak var broadcastPlayer: BambuserPlayerView!
    @IBOutlet weak var broadcastGlobePositionView: UIView!
    private var breathVisualizationViewInitialFrame: CGRect?
    
    var breatheDate: Date? {
        get {
            return UserDefaults.standard.value(forKey: "breatheDate") as? Date
        }
    }
    var dateFormatter = DateFormatter()
    
    var breathAnimator: BreathAnimator?
    var broadcastLoadingIndicatorView: NVActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(breathView)
        setupInitialViewValues()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        breathVisualizationViewInitialFrame = breathVisualizationBoundingView.frame
        breathView.frame = breathVisualizationBoundingView.frame
        breathView.autoresizesSubviews = true
        
        globeViewController.view.frame = breathView.bounds
        addChild(globeViewController)
        globeViewController.didMove(toParent: self)
        
        breathView.addSubview(globeViewController.view)
        
        self.breathingInLabel.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        self.countdownView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        self.setupBaseViewState()
        
        beginPollingForLiveBroadcast()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateBreatheDate(_:)), name: NSNotification.Name(rawValue: "breatheDateSet"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(broadcastStartedNotification(_:)), name: NSNotification.Name(rawValue: "broadcastStarted"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(broadcastEndedNotification(_:)), name: NSNotification.Name(rawValue: "broadcastEnded"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appBecameActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    fileprivate func setupInitialViewValues() {
        countdownLabel = CountdownLabel(frame: countdownView.bounds)
        countdownLabel?.font = .systemFont(ofSize: 23.0)
        countdownView.addSubview(countdownLabel!)
        
        broadcastLoadingIndicatorView = NVActivityIndicatorView(frame: broadcastGlobePositionView.frame, type: .orbit, color: .label, padding: -10)
        view.addSubview(broadcastLoadingIndicatorView!)
        view.sendSubviewToBack(broadcastLoadingIndicatorView!)
        broadcastLoadingIndicatorView?.alpha = 0
        
        self.breathingInLabel.alpha = 0
        self.countdownView.alpha = 0
        self.breathVisualizationBoundingView.alpha = 0
        self.postBreathingView.alpha = 0
        self.countdownView.backgroundColor = .clear
        self.breathView.alpha = 0
        
        dateFormatter.dateFormat = "h:mma"
        dateFormatter.amSymbol = "am"
        dateFormatter.pmSymbol = "pm"
    }
    
    private func setupBaseViewState() {
        // Hide irrelevant views
        hidePostBreathingAndInstructionsViews()
        showBreathView()
        beginInfiniteBreathing()
        // Show the countdown...with delay for visual appeal
        DispatchQueue.main.asyncAfter(deadline: .now()+0.8) {
            self.showCountdown()
        }
    }
    
    private func setupLiveBroadcastState() {
        hideCountdownLabels()
        hidePostBreathingAndInstructionsViews()
        breathAnimator?.stopBreathing()
        UIView.animate(withDuration: 2.0, delay: 0, options: .curveEaseInOut, animations: {
            self.breathView.transform = .identity
            self.breathView.frame = self.broadcastGlobePositionView.frame
        }) { (_) in
            self.broadcastLoadingIndicatorView?.alpha = 1
        }
    }
    
    private func setupPostBreathingView() {
        hidePlayerView()
        hideCountdownLabels()
        breathAnimator?.stopBreathing()
        self.broadcastLoadingIndicatorView?.alpha = 0
        let convertedFrame = self.postBreathingView.globeView.convert(self.postBreathingView.globeView.bounds, to: self.view)
        UIView.animate(withDuration: 2.0, animations: {
            self.postBreathingView.alpha = 1
        })
        UIView.animate(withDuration: 2.0, delay: 0.33, options: .curveEaseInOut, animations: {
            self.breathView.frame = convertedFrame
        })
        UIView.animate(withDuration: 1.2, delay: 0.33, options: .curveEaseInOut, animations: {
            self.breathView.transform = CGAffineTransform(scaleX: 2.2, y: 2.2)
        }) { (_) in
            UIView.animate(withDuration: 0.8, delay: 0, options: .curveEaseInOut, animations: {
                self.breathView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }) { (_) in
                UIView.animate(withDuration: 1.2, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
                    self.breathView.transform = .identity
                }) { (_) in
                    self.globeViewController.rotateGracefully()
                }
            }
        }
    }
    
    private func showBreathView() {
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
    
    private func beginInfiniteBreathing() {
        breathAnimator = BreathAnimator(minScale: 0.7, maxScale: 1, numberOfBreathCycles: Int.max, inBreathDuration: 4, outBreathDuration: 6)
        breathAnimator?.makeBreathe(view: breathView, completion: nil)
    }
    
    private func stopInfiniteBreathing() {
        breathAnimator?.stopBreathing()
    }
    
    private func showCountdown() {
        if let date = breatheDate {
            refreshBreathCountdown()
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
    
    private func hidePostBreathingAndInstructionsViews() {
        UIView.animate(withDuration: 0.5, delay: 0, animations: {
            self.postBreathingView.alpha = 0
            self.broadcastLoadingIndicatorView?.alpha = 0
        })
    }
    
    private func hideCountdownLabels() {
        UIView.animate(withDuration: 0.5, delay: 0.25, animations: {
            self.countdownView.alpha = 0
            self.countdownView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        })
        UIView.animate(withDuration: 0.5, delay: 0.5, animations: {
            self.breathingInLabel.alpha = 0
            self.breathingInLabel.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        })
    }
    
    private func hidePlayerView() {
        self.broadcastPlayer.broadcastStopped()
    }
    
    func beginPollingForLiveBroadcast() {
        Networker.checkForLiveBroadcast { (broadcast) in
            guard let cast = broadcast else {
                DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                    self.beginPollingForLiveBroadcast()
                }
                return
            }
            self.broadcastIsLive(cast)
        }
    }
    
    private func refreshBreathCountdown() {
        if var date = self.breatheDate {
            // Check to see if the breatheDate is in the past
            if date < Date() {
                // Now set the date with the proper hour and minute of the breathe time
                let calendar = Calendar.current
                let previousDateComponents = calendar.dateComponents([.hour, .minute], from: date)
                let currentDateComponents = calendar.dateComponents([.hour, .minute, .day, .year], from: Date())
                var dateComponents = currentDateComponents
                dateComponents.hour = previousDateComponents.hour
                dateComponents.minute = previousDateComponents.minute
                dateComponents.second = 0
                date = calendar.date(from: dateComponents)!
                
                // compare to see if its already happened and if so push it up another day
                if date < Date() {
                    date = date.addingTimeInterval(86400)
                }
            }
            countdownLabel?.setCountDownDate(targetDate: date as NSDate)
            countdownLabel?.start()
        }
    }
    
    @objc func updateBreatheDate(_ notification: Notification) {
        refreshBreathCountdown()
    }
    
    @objc func broadcastStartedNotification(_ notification: Notification) {
        let broadcast = notification.userInfo?["broadcastDetails"] as! Broadcast
        print("Broadcast details received")
        print(broadcast)
        broadcastIsLive(broadcast)
    }
    
    @objc func broadcastEndedNotification(_ notification: Notification) {
        playerStopped()
    }
    
    @objc func appBecameActive(_ notification: Notification) {
        Networker.checkForLiveBroadcast { (broadcast) in
            guard let cast = broadcast else { return }
            self.broadcastIsLive(cast)
        }
    }
    
    private func broadcastIsLive(_ broadcast: Broadcast) {
        setupLiveBroadcastState()
        broadcastPlayer.broadcastIsLive(broadcast, delegate: self)
    }
    
    private func playerStopped() {
        // if no live broadcast...transition to post breathing
        // this can fire from the player simply because the user backgrounds the app
        // we want to prevent transitioning to the post experience in this case
        Networker.checkForLiveBroadcast { (broadcast) in
            guard let cast = broadcast else {
                self.setupPostBreathingView()
                self.beginPollingForLiveBroadcast()
                return
            }
            self.broadcastIsLive(cast)
        }
    }
    
    //TODO: testing purposes only...remove
    @IBAction func beginBreathingButton(_ sender: UIButton) {
//        setupLiveBroadcastState()
        let date = Date(timeInterval: 3, since: Date())
        countdownLabel?.setCountDownDate(targetDate: date as NSDate)
        countdownLabel?.start()
        setupLiveBroadcastState()
    }
    
    @IBAction func resetButton(_ sender: Any) {
        setupPostBreathingView()
    }
    /////
}

extension ViewController: BambuserPlayerViewDelegate {
    func playerDidBeginBuffering() {
        broadcastLoadingIndicatorView?.startAnimating()
    }
    
    func playerDidPlay() {
        broadcastLoadingIndicatorView?.stopAnimating()
    }
    
    func playerDidStop() {
        broadcastLoadingIndicatorView?.stopAnimating()
        playerStopped()
    }
    
    func didError() {
        broadcastLoadingIndicatorView?.stopAnimating()
        playerStopped()
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
