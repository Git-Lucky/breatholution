import UIKit
import AVFoundation

class InfiniteBreathViewController: UIViewController {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var logoView: LogoView!
    @IBOutlet weak var breathingViewInfinitePosition: UIView!
    @IBOutlet weak var breathingViewLivePosition: UIView!
    @IBOutlet weak var breathingTimeTextView: BreathingTimeTextView!
    @IBOutlet weak var countdownView: CountdownView!
    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var livePlayer: BambuserPlayerView!
    
    var breathingView = InfiniteBreathingView()
    var playerLayer: AVPlayerLayer?
    var breatheDate: Date? {
        get {
            return UserDefaults.standard.value(forKey: "breatheDate") as? Date
        }
    }
    var dateFormatter = DateFormatter()
    var breathAnimator: BreathAnimator?
    
    fileprivate var player: AVPlayer? {
        didSet { player?.play() }
    }
    fileprivate var playerObserver: Any?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inviteButton.layer.cornerRadius = 10.0
        inviteButton.titleLabel?.addCharacterSpacing()
        breathingViewLivePosition.backgroundColor = .clear
        breathingViewInfinitePosition.backgroundColor = .clear
        
        setupInfiniteBackroundVideo()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "breatheDateSet"), object: nil, queue: nil) { notification in
            self.refreshBreathCountdown()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshBreathCountdown()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        breathingView.frame = breathingViewInfinitePosition.frame
        view.addSubview(breathingView)
        
        playerLayer?.frame = view.bounds
        playerLayer?.transform = CATransform3DMakeScale(1.2, 1.2, 1)
        
        beginInfiniteBreathing()
        
        beginPollingForLiveBroadcast()
    }
    
    @IBAction func demoLiveBreathingButtonTapped(_ sender: Any) {
        setupLiveBroadcastState()
        
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            self.playerLayer = self.videoPlayerLayer(forResource: "pocBreath", withExtension: "mov", looping: false)
            self.playerLayer?.frame = self.view.bounds
            self.playerLayer?.transform = CATransform3DMakeScale(1.2, 1.2, 1)
            
            self.view.layer.insertSublayer(self.playerLayer!, at: 0)
        }
    }
    
    @IBAction func inviteAFriendTapped(_ sender: UIButton) {
        let items: [Any] = ["Come breathe with me!", URL(string: "https://www.breatholution.com")!]
        presentActivityViewController(sourceView: sender, activityItems: items)
    }
    
    func presentActivityViewController(sourceView: UIView, activityItems: [Any]) {
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)

        activityViewController.popoverPresentationController?.sourceView = sourceView
        activityViewController.popoverPresentationController?.sourceRect = sourceView.bounds

        present(activityViewController, animated: true, completion: nil)
    }
    
    private func beginInfiniteBreathing() {
        breathAnimator = BreathAnimator(minScale: 0.7, maxScale: 1, numberOfBreathCycles: Int.max, inBreathDuration: 4, outBreathDuration: 6)
        breathAnimator?.makeBreathe(view: breathingView, completion: nil)
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
    
    private func broadcastIsLive(_ broadcast: Broadcast) {
        setupLiveBroadcastState()
        livePlayer.broadcastIsLive(broadcast, delegate: self)
    }
    
    private func setupLiveBroadcastState() {
        breathAnimator?.stopBreathing()
        hideInfiniteElements()
        UIView.animate(withDuration: 2.0, delay: 0, options: .curveEaseInOut, animations: {
            self.breathingView.transform = .identity
            self.breathingView.frame = self.breathingViewLivePosition.frame
            self.view.layoutIfNeeded()
        })
        view.bringSubviewToFront(livePlayer)
        view.bringSubviewToFront(breathingView)
    }
    
    private func setupInfiniteBreathingState() {
        UIView.animate(withDuration: 2.0, delay: 0, options: .curveEaseInOut, animations: {
            self.breathingView.transform = .identity
            self.breathingView.frame = self.breathingViewInfinitePosition.frame
            self.view.layoutIfNeeded()
        })
        beginInfiniteBreathing()
        DispatchQueue.main.asyncAfter(deadline: .now()+0.8) {
            self.showInfiniteElements()
        }
    }
    
    private func setupInfiniteBackroundVideo() {
        playerLayer = videoPlayerLayer(forResource: "InfinityBreathingBackgroundVideo", withExtension: "mp4", looping: true)
//        playerLayer?.player?.seek(to: CMTimeMakeWithSeconds(30, preferredTimescale: 1))
//        playerLayer?.player?.volume = 0
        playerLayer?.videoGravity = .resizeAspectFill
        playerLayer?.frame = view.bounds
        playerLayer?.transform = CATransform3DMakeScale(1.2, 1.2, 1)
        view.layer.insertSublayer(playerLayer!, at: 0)
    }
    
    private func hideInfiniteElements() {
        UIView.animate(withDuration: 0.5, delay: 0, animations: {
            self.logoView.alpha = 0
            self.logoView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.inviteButton.alpha = 0
            self.inviteButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        })
        UIView.animate(withDuration: 0.5, delay: 0.25, animations: {
            self.countdownView.alpha = 0
            self.countdownView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        })
        UIView.animate(withDuration: 0.5, delay: 0.5, animations: {
            self.breathingTimeTextView.alpha = 0
            self.breathingTimeTextView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        })
    }
    
    private func showInfiniteElements() {
        UIView.animate(withDuration: 0.5, delay: 0, animations: {
            self.logoView.alpha = 1
            self.logoView.transform = .identity
            self.inviteButton.alpha = 1
            self.inviteButton.transform = .identity
        })
        UIView.animate(withDuration: 0.5, delay: 0.25, animations: {
            self.countdownView.alpha = 1
            self.countdownView.transform = .identity
        })
        UIView.animate(withDuration: 0.5, delay: 0.5, animations: {
            self.breathingTimeTextView.alpha = 1
            self.breathingTimeTextView.transform = .identity
        })
    }
    
    private func playerStopped() {
        // if no live broadcast...transition to post breathing
        // this can fire from the player simply because the user backgrounds the app
        // we want to prevent transitioning to the post experience in this case
        Networker.checkForLiveBroadcast { (broadcast) in
            guard let cast = broadcast else {
                // TODO: transition to post breathing experience
                self.setupInfiniteBreathingState()
                self.beginPollingForLiveBroadcast()
                return
            }
            self.broadcastIsLive(cast)
        }
    }
    
    fileprivate func refreshBreathCountdown() {
        if let date = self.breatheDate {
            breathingTimeTextView.setTimeText(date)
            countdownView.setCountdownDate(date)
        }
    }
    
    fileprivate func videoPlayerLayer(forResource resource: String, withExtension: String, looping: Bool) -> AVPlayerLayer? {
        playerLayer?.removeFromSuperlayer()
        guard let url = Bundle.main.url(forResource: resource, withExtension:withExtension) else {
            debugPrint("video not found")
            return nil
        }
        let player = AVPlayer(url: url)
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient)
        } catch let error as NSError {
            print(error)
        }

        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error as NSError {
            print(error)
        }
        if (looping == true) {
            let resetPlayer = {
                player.seek(to: CMTime.zero)
                player.play()
            }
            playerObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: nil) { notification in
                resetPlayer()
            }
        } else {
            playerObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: nil) { notification in
                self.videoEnded()
            }
        }
        self.player = player
        
        return AVPlayerLayer(player: player)
    }
    
    fileprivate func videoEnded() {
        setupInfiniteBackroundVideo()
        setupInfiniteBreathingState()
    }
}

extension InfiniteBreathViewController: BambuserPlayerViewDelegate {
    func playerDidBeginBuffering() {
//        broadcastLoadingIndicatorView?.startAnimating()
    }
    
    func playerDidPlay() {
//        broadcastLoadingIndicatorView?.stopAnimating()
    }
    
    func playerDidStop() {
//        broadcastLoadingIndicatorView?.stopAnimating()
        playerStopped()
    }
    
    func didError() {
//        broadcastLoadingIndicatorView?.stopAnimating()
        playerStopped()
    }
}

extension InfiniteBreathViewController {
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
}
