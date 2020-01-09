import UIKit

class GlobeViewController: WhirlyGlobeViewController {
        
    let useSatellite = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clearColor = .clear
        
        setUpWithGlobe(self)
        
        setPosition(MaplyCoordinate(x: 0, y: 0), height: 1)
        setAutoRotateInterval(0.00001, degrees:4)
        roll = 5
        
        self.view.isUserInteractionEnabled = false
                
//        startLocationTracking(with: self, useHeading: false, useCourse: false, simulate: false)
    }
    
    var imageLoader : MaplyQuadImageLoader? = nil
    
    // Put together a quad sampler layer
    func setupLoader(_ baseVC: MaplyBaseViewController) -> MaplyQuadImageLoader? {
        // Stamen tile source
        let cacheDir = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
        let thisCacheDir = "\(cacheDir)/stamentiles/"
        let tileInfo = MaplyRemoteTileInfoNew(baseURL: "http://tile.stamen.com/watercolor/{z}/{x}/{y}.png",
                                              minZoom: Int32(4),
                                              maxZoom: Int32(4))
        tileInfo.cacheDir = thisCacheDir
        
        // Parameters describing how we want a globe broken down
        let sampleParams = MaplySamplingParams()
        sampleParams.coverPoles = true
        sampleParams.edgeMatching = true
        sampleParams.minZoom = tileInfo.minZoom()
        sampleParams.maxZoom = tileInfo.maxZoom()
        sampleParams.singleLevel = false
        
        guard let imageLoader = MaplyQuadImageLoader(params: sampleParams, tileInfo: tileInfo, viewC: baseVC) else {
            return nil
        }
        imageLoader.imageFormat = .imageUShort565;
        
//        imageLoader.debugMode = true
        
        return imageLoader
    }
    
    func setupSatalliteTiles(_ vc: WhirlyGlobeViewController) {
        if let tileSource = MaplyMBTileSource(mbTiles: "satellite"), let layer = MaplyQuadImageTilesLayer(tileSource: tileSource) {
            layer.coverPoles = true
            layer.handleEdges = true
            layer.singleLevelLoading = true
//            layer.waitLoad = false
            layer.borderTexel = 100
            layer.drawPriority = 100
            vc.add(layer)
        }
    }
    
    func setUpWithGlobe(_ globeVC: WhirlyGlobeViewController) {
        if (useSatellite) {
            setupSatalliteTiles(globeVC)
        } else {
            imageLoader = setupLoader(globeVC)
        }
    }
    
    func markLocation(_ location: CLLocation) {
        let coordinates = MaplyCoordinateMakeWithDegrees(Float(location.coordinate.longitude), Float(location.coordinate.latitude))
        let circle = MaplyShapeCircle()
        circle.center = coordinates
        circle.radius = 0.01
        
        addShapes([circle], desc: [kMaplyColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0.75)])
    }
}

extension GlobeViewController: MaplyLocationTrackerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChange status: CLAuthorizationStatus) {
        if let location = manager.location {
            markLocation(location)
//            let coordinate = MaplyCoordinate(x: Float(location.coordinate.longitude), y: Float(location.coordinate.latitude))
//            animate(toPosition: coordinate, time: 4)
//            setAutoRotateInterval(0.00001, degrees:4)
            stopLocationTracking()
        }
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
