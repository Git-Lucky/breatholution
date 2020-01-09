import UIKit

protocol BambuserPlayerViewDelegate {
    func didEndBroadcast()
    func didError()
}

class BambuserPlayerView: UIView, BambuserPlayerDelegate {
    var bambuserPlayer: BambuserPlayer?
    var currentBroadcastID: String?
    var delegate: BambuserPlayerViewDelegate?
    var bufferingOverlayView: UIView?
    var spinnerView: UIActivityIndicatorView?
    
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
        
        player.playVideo(broadcast.url)
        
        bufferingOverlayView = UIView(frame: frame)
        bufferingOverlayView?.backgroundColor = .label
        bufferingOverlayView?.alpha = 0
        spinnerView = UIActivityIndicatorView(frame: bufferingOverlayView!.bounds)
        bufferingOverlayView?.addSubview(spinnerView!)
        
        addSubview(bufferingOverlayView!)
    }

    func playbackStatusChanged(_ status: BambuserPlayerState) {
        switch status {
        case kBambuserPlayerStateLoading:
            print("Loading")
            break
            
        case kBambuserPlayerStateBuffering:
            //TODO: Make a better buffering animation
            bringSubviewToFront(bufferingOverlayView!)
            spinnerView?.startAnimating()
            bufferingOverlayView?.alpha = 0.8
            print("Buffering")
            break
            
        case kBambuserPlayerStatePlaying:
            bufferingOverlayView?.alpha = 0
            spinnerView?.stopAnimating()
            
            addSubview(bambuserPlayer!)
            print("Playing")
            break
            
        case kBambuserPlayerStatePaused:
            print("Paused")
            break

        case kBambuserPlayerStateStopped:
            delegate?.didEndBroadcast()
            currentBroadcastID = nil
            bambuserPlayer?.stopVideo()
            bambuserPlayer?.removeFromSuperview()
            bufferingOverlayView?.removeFromSuperview()
            print("Stopped")
            break

        case kBambuserPlayerStateError:
            Networker.checkForLiveBroadcast { (broadcast) in
                if (broadcast != nil){
                    self.bambuserPlayer?.playVideo(broadcast?.url)
                } else {
                    self.delegate?.didError()
                }
            }
            print("Player state error")
            break
            
        default:
            print(status.rawValue)
            break
        }
    }
}
