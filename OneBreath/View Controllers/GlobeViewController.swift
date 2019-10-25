import UIKit

class GlobeViewController: WhirlyGlobeViewController {
    
    var animator: AnimatorOrchestrator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clearColor = .white
        
        setUpWithGlobe(self)
        
        setPosition(MaplyCoordinate(x: 0, y: 0), height: 4)
        
        panGesture = false
//        pinchGesture = false
        zoomAroundPinch = false
//        rotateGesture = false
        doubleTapZoomGesture = false
        twoFingerTapGesture = false
        doubleTapDragGesture = false
        roll = 5
        
        setAutoRotateInterval(0.01, degrees: 11)

        animator = AnimatorOrchestrator()
        animator?.beginBreathingAnimationSequence(view: view)
    }
    
//    func begin
    
    var imageLoader : MaplyQuadImageLoader? = nil
    
    @IBAction func beginBreathing(_ sender: Any) {
        
    }
    // Put together a quad sampler layer
    func setupLoader(_ baseVC: MaplyBaseViewController) -> MaplyQuadImageLoader? {
        // Stamen tile source
        let cacheDir = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
        let thisCacheDir = "\(cacheDir)/stamentiles/"
        let tileInfo = MaplyRemoteTileInfoNew(baseURL: "http://tile.stamen.com/watercolor/{z}/{x}/{y}.png",
                                              minZoom: Int32(3),
                                              maxZoom: Int32(5))
        tileInfo.cacheDir = thisCacheDir
        
        // Parameters describing how we want a globe broken down
        let sampleParams = MaplySamplingParams()
        sampleParams.coverPoles = true
        sampleParams.edgeMatching = true
        sampleParams.minZoom = tileInfo.minZoom()
        sampleParams.maxZoom = tileInfo.maxZoom()
        sampleParams.singleLevel = true
        
        guard let imageLoader = MaplyQuadImageLoader(params: sampleParams, tileInfo: tileInfo, viewC: baseVC) else {
            return nil
        }
        imageLoader.imageFormat = .imageUShort565;
//        imageLoader.debugMode = true
        
        return imageLoader
    }
    
    func setUpWithGlobe(_ globeVC: WhirlyGlobeViewController) {
        imageLoader = setupLoader(globeVC)
    }
}

extension GlobeViewController {
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
}
