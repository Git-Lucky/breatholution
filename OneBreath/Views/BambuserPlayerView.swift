import UIKit

protocol BambuserPlayerViewDelegate {
    func playerDidBeginBuffering()
    func playerDidPlay()
    func playerDidStop()
    func didError()
}

class BambuserPlayerView: UIView, BambuserPlayerDelegate {
    var bambuserPlayer: BambuserPlayer?
    var currentBroadcastID: String?
    var delegate: BambuserPlayerViewDelegate?
    var bufferingOverlayView: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
    
    }
    
    func broadcastIsLive(_ broadcast: Broadcast, delegate: BambuserPlayerViewDelegate) {
        guard broadcast.id != currentBroadcastID else {
            return
        }
        self.delegate = delegate
        currentBroadcastID = broadcast.id
        bambuserPlayer?.removeFromSuperview()
        bambuserPlayer = BambuserPlayer()
        guard let player = bambuserPlayer else { return }
        
        player.delegate = self
        player.requiredBroadcastState = kBambuserBroadcastStateLive
        player.applicationId = "YEZ8MWRhzDqo5SWQCteYmQ"
        player.backgroundColor = .clear
        player.frame = bounds
        player.videoScaleMode = VideoScaleAspectFill
        
        player.playVideo(broadcast.url)
        
        bufferingOverlayView = UIView(frame: frame)
        bufferingOverlayView?.backgroundColor = .clear
        bufferingOverlayView?.alpha = 0
        
        addSubview(bufferingOverlayView!)
    }
    
    func broadcastStopped() {
        currentBroadcastID = nil
        bambuserPlayer?.stopVideo()
        bambuserPlayer?.removeFromSuperview()
        bufferingOverlayView?.removeFromSuperview()
    }

    func playbackStatusChanged(_ status: BambuserPlayerState) {
        switch status {
        case kBambuserPlayerStateLoading:
            print("Loading")
            break
            
        case kBambuserPlayerStateBuffering:
            delegate?.playerDidBeginBuffering()
            //TODO: Make a better buffering animation
//            bringSubviewToFront(bufferingOverlayView!)
//            spinnerView?.startAnimating()
//            bufferingOverlayView?.alpha = 1
            print("Buffering")
            break
            
        case kBambuserPlayerStatePlaying:
//            bufferingOverlayView?.alpha = 0
//            spinnerView?.stopAnimating()
            delegate?.playerDidPlay()
            
            addSubview(bambuserPlayer!)
            print("Playing")
            break
            
        case kBambuserPlayerStatePaused:
            print("Paused")
            break

        case kBambuserPlayerStateStopped:
            broadcastStopped()
            delegate?.playerDidStop()
            print("Stopped")
            break

        case kBambuserPlayerStateError:
            Networker.checkForLiveBroadcast { (broadcast) in
                guard let cast = broadcast, let delegate = self.delegate else {
                    self.delegate?.didError()
                    return
                }
                self.broadcastIsLive(cast, delegate: delegate)
            }
            print("Player state error")
            break
            
        default:
            print(status.rawValue)
            break
        }
    }
}
