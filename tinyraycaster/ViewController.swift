//
//  ViewController.swift
//  tinyraycaster
//
//  Created by Jeremy Giberson on 2/12/19.
//  Copyright © 2019 Jeremy Giberson. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet var uiGameView: GameView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            
            self.uiGameView.player_a += 0.05
            self.uiGameView.setNeedsDisplay(self.uiGameView.visibleRect)
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}
