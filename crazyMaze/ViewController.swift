//
//  ViewController.swift
//  crazyMaze
//
//  Created by Tenju Paul on 9/6/18.
//  Copyright © 2018 Tenju Paul. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func playButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "playSegue", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

