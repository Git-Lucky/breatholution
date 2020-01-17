import UIKit
import AVFoundation

class InfiniteBreathViewController: UIViewController {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var logoView: LogoView!
    @IBOutlet weak var breathingView: UIView!
    @IBOutlet weak var breathingTimeTextView: BreathingTimeTextView!
    @IBOutlet weak var countdownView: CountdownView!
    @IBOutlet weak var inviteButton: UIButton!
    
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
        
        if let date = self.breatheDate {
            breathingTimeTextView.setTimeText(date)
            countdownView.setCountdownDate(date)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshBreathCountdown(_:)), name: NSNotification.Name(rawValue: "breatheDateSet"), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let playerLayer = videoPlayerLayer() {
            playerLayer.frame = view.bounds
            playerLayer.videoGravity = .resizeAspectFill
            playerLayer.transform = CATransform3DMakeScale(1.1, 1.1, 1)
            view.layer.insertSublayer(playerLayer, at: 0)
        }
        
        beginInfiniteBreathing()
    }
    
    private func beginInfiniteBreathing() {
        breathAnimator = BreathAnimator(minScale: 0.7, maxScale: 1, numberOfBreathCycles: Int.max, inBreathDuration: 4, outBreathDuration: 6)
        breathAnimator?.makeBreathe(view: breathingView, completion: nil)
    }
    
    func videoPlayerLayer() -> AVPlayerLayer? {
        guard let url = Bundle.main.url(forResource: "InfinityBreathingBackgroundVideo", withExtension:"mp4") else {
            debugPrint("video not found")
            return nil
        }
        let player = AVPlayer(url: url)
        let resetPlayer = {
            player.seek(to: CMTime.zero)
            player.play()
        }
        playerObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: nil) { notification in
            resetPlayer()
        }
        self.player = player
        return AVPlayerLayer(player: player)
    }
    
    @objc func refreshBreathCountdown(_ notification: Notification) {
        if let date = self.breatheDate {
            breathingTimeTextView.setTimeText(date)
            countdownView.setCountdownDate(date)
        }
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
