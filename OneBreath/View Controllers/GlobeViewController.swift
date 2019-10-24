import UIKit

class GlobeViewController: WhirlyGlobeViewController {
    
    private let doGlobe = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        frameInterval = 2
        
        if let tileSource = MaplyMBTileSource(mbTiles: "geography-class_medres"),
            let layer = MaplyQuadImageTilesLayer(tileSource: tileSource) {
            layer.handleEdges = false
            layer.coverPoles = true
            layer.requireElev = false
            layer.waitLoad = false
            layer.drawPriority = 0
            layer.singleLevelLoading = false
            add(layer)
            
            height = 0.8
            animate(toPosition: MaplyCoordinateMakeWithDegrees(-3.6704803, 40.5023056), time: 1.0)
        }
    }
    
}
