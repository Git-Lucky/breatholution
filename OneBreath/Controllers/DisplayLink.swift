import UIKit

protocol DisplayLinkDelegate {
    func displayLinkDidUpdate(_ displayLink: CADisplayLink)
}

class DisplayLink {
    
    private var delegate: DisplayLinkDelegate?
    
    var displayLink: CADisplayLink?
    
    func startUpdates(delegate: DisplayLinkDelegate) {
        self.delegate = delegate
        
        stopDisplayLink()
        
        displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink?.add(to: .current, forMode: .common)
    }
    
    func stopUpdates() {
        stopDisplayLink()
    }
    
    @objc func update(_ displayLink: CADisplayLink) {
        self.delegate?.displayLinkDidUpdate(displayLink)
    }
    
    func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }
}
