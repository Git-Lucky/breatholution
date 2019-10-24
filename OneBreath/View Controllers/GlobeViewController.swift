import UIKit

class GlobeViewController: UIViewController {
    private var theViewC: MaplyBaseViewController?
    
    override func viewDidLoad() {
      super.viewDidLoad()
          
      // Create an empty globe and add it to the view
      theViewC = WhirlyGlobeViewController()
      self.view.addSubview(theViewC!.view)
      theViewC!.view.frame = self.view.bounds
      addChildViewController(theViewC!)
    }
}
