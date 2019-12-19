import AVFoundation

enum AudioSegment {
    case welcome
    case setIntention
    case still
}

protocol AudioManagerDelegate {
    func didFinishPlayingSegment(_ segment: AudioSegment)
}

class AudioManager: NSObject {
    var player: AVAudioPlayer?
    let delegate: AudioManagerDelegate
    
    init(withDelegate delegate: AudioManagerDelegate) {
        self.delegate = delegate
    }
    
    var currentSegment: AudioSegment?
    
    func beginWelcome() {
        currentSegment = .welcome
        playSound(name: "welcome")
    }
    
    private func playSound(name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "m4a") else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.m4a.rawValue)

            /* iOS 10 and earlier require the following line:
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */

            guard let player = player else { return }
            
            player.prepareToPlay()
            player.delegate = self
            player.play()

        } catch let error {
            print(error.localizedDescription)
        }
    }
}

extension AudioManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        guard let currentSegment = currentSegment else { return }
        delegate.didFinishPlayingSegment(currentSegment)
    }
}
