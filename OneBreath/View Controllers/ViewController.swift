//
//  ViewController.swift
//  OneBreath
//
//  Created by Timothy Hise on 10/20/19.
//  Copyright © 2019 One. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var breathVisualizationView: BreathVisualizationView!
    var animator: AnimatorOrchestrator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        animator = AnimatorOrchestrator()
    }
    
    @IBAction func beginBreathingButton(_ sender: Any) {
        animator?.beginBreathingAnimationSequence(view: breathVisualizationView)
    }
    
}

extension ViewController {
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
}

