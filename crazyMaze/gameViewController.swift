//
//  gameViewController.swift
//  crazyMaze
//
//  Created by Tenju Paul on 9/6/18.
//  Copyright © 2018 Tenju Paul. All rights reserved.
//

import UIKit
import CoreMotion
import AVFoundation

class gameViewController: UIViewController {
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBAction func quitButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    var motionManager = CMMotionManager()
    let opQueue = OperationQueue()
    var timer = Timer()
    var gameOver: Bool = false
    
    var gameMap:[[Int]]=[
        
        [2,0,0,0,0,3,
        1,0,0,0,0,1,
        1,1,1,0,1,1,
        0,0,1,0,1,0,
        0,0,1,0,1,0,
        0,1,1,0,1,0,
        0,1,0,0,1,0,
        0,1,1,1,1,0],
        
        [0,4,0,0,0,0,
         0,1,1,1,1,4,
         0,1,0,0,1,0,
         0,1,0,0,1,0,
         2,1,4,0,1,0,
         0,0,0,0,1,0,
         0,0,0,3,1,0,
         0,0,0,0,4,0],
        
        [0,4,0,0,0,0,
         0,1,1,1,1,4,
         0,1,0,0,1,0,
         0,1,0,0,1,0,
         2,1,4,0,1,0,
         0,0,0,0,1,0,
         0,0,0,3,1,0,
         0,0,0,0,4,0]
        
    ]
    
    var mapIdx = 0
    var gameTimer = Timer()
    var seconds: Int = 10
    var newLevel: Bool = true
    var initialPitch: Double = 0.0
    var initialRoll: Double = 0.0
    var gameDelay = Timer()
    var tapSound = AVAudioPlayer()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        levelLabel.text = "LVL 1"
        // Do any additional setup after loading the view.
        updateUI()
        timerLabel.text = "00:\(seconds)"
        timer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(gameViewController.updateUI), userInfo: nil, repeats: true)
        gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(gameViewController.setTimer), userInfo: nil, repeats: true)
        if motionManager.isDeviceMotionAvailable {
            print("We can detect device motion")
            gameDelay = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(gameViewController.startReadingMotionData), userInfo: nil, repeats: false)
        }
        else {
            print("We cannot detect device motion")
        }
        do {
            let tapSoundPath = Bundle.main.path(forResource: "latch_click", ofType: "mp3")
            try tapSound = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: tapSoundPath!) as URL)
            tapSound.volume = 1
        } catch {
            //process error
        }
    }
    @objc func setTimer() {
        //print("start timer")
        seconds -= 1
        timerLabel.text = "00:0\(seconds)"
        if seconds == 0 {
            //timerLabel.text = "GAME OVER"
            gameTimer.invalidate()
            let alert = UIAlertController(title: "GAME OVER", message: "You idiot!!!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK...", comment: "Default action"), style: .default, handler: nil
            ))
            self.present(alert, animated: true, completion: nil)
            gameOver = true
        }
    }
    @IBOutlet var singleGridView: [UIView]!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func startReadingMotionData() {
        // set read speed
        motionManager.deviceMotionUpdateInterval = 0.1
        // start reading
        motionManager.startDeviceMotionUpdates(to: opQueue) {
            (data: CMDeviceMotion?, error: Error?) in
            
            if let mydata = data {
                // print("pitch", self.degrees(mydata.attitude.pitch)) // -forward, +backward
                // print("roll", self.degrees(mydata.attitude.roll)) // -left, +right
                if let playerIdx = self.gameMap[self.mapIdx].index(of: 2) {
                    
                // forward backward
                    if self.newLevel == true {
                        self.initialRoll = self.degrees(mydata.attitude.roll)
                        self.initialPitch = self.degrees(mydata.attitude.pitch)
                        self.newLevel = false
                    }
                    
                    if self.degrees(mydata.attitude.pitch) < self.initialPitch - 15 && !self.gameOver {
                        if playerIdx - 6 >= 0 && (self.gameMap[self.mapIdx][playerIdx - 6] == 1 || self.gameMap[self.mapIdx][playerIdx - 6] == 3 || self.gameMap[self.mapIdx][playerIdx - 6] == 4) {
                            
                            if self.gameMap[self.mapIdx][playerIdx - 6] == 3 {
                                self.gameMap[self.mapIdx][playerIdx - 6] = 2
                                self.gameMap[self.mapIdx][playerIdx] = 1
                                if self.tapSound.isPlaying {
                                    self.tapSound.pause()
                                }
                                self.tapSound.currentTime = 0
                                self.tapSound.play()
                                self.winAlert()
                            }
                            else if self.gameMap[self.mapIdx][playerIdx - 6] == 4 {
                                self.gameMap[self.mapIdx][playerIdx - 6] = 2
                                self.gameMap[self.mapIdx][playerIdx] = 1
                                if self.tapSound.isPlaying {
                                    self.tapSound.pause()
                                }
                                self.tapSound.currentTime = 0
                                self.tapSound.play()
                                self.redAlert()
                            }
                            else {
                                self.gameMap[self.mapIdx][playerIdx - 6] = 2
                                self.gameMap[self.mapIdx][playerIdx] = 1
                                if self.tapSound.isPlaying {
                                    self.tapSound.pause()
                                }
                                self.tapSound.currentTime = 0
                                self.tapSound.play()
                            }
                            
                        }
                    } else if self.degrees(mydata.attitude.pitch) > self.initialPitch + 15 && !self.gameOver {
                        if playerIdx + 6 <= 47 && (self.gameMap[self.mapIdx][playerIdx + 6] == 1 || self.gameMap[self.mapIdx][playerIdx + 6] == 3 || self.gameMap[self.mapIdx][playerIdx + 6] == 4) {
                            
                            if self.gameMap[self.mapIdx][playerIdx + 6] == 3 {
                                self.gameMap[self.mapIdx][playerIdx + 6] = 2
                                self.gameMap[self.mapIdx][playerIdx] = 1
                                if self.tapSound.isPlaying {
                                    self.tapSound.pause()
                                }
                                self.tapSound.currentTime = 0
                                self.tapSound.play()
                                self.winAlert()
                            }
                            else if self.gameMap[self.mapIdx][playerIdx + 6] == 4 {
                                self.gameMap[self.mapIdx][playerIdx + 6] = 2
                                self.gameMap[self.mapIdx][playerIdx] = 1
                                if self.tapSound.isPlaying {
                                    self.tapSound.pause()
                                }
                                self.tapSound.currentTime = 0
                                self.tapSound.play()
                                self.redAlert()
                            }
                            else {
                                self.gameMap[self.mapIdx][playerIdx + 6] = 2
                                self.gameMap[self.mapIdx][playerIdx] = 1
                                if self.tapSound.isPlaying {
                                    self.tapSound.pause()
                                }
                                self.tapSound.currentTime = 0
                                self.tapSound.play()
                            }
                        }
                    }   else if self.degrees(mydata.attitude.roll) < self.initialRoll - 15 && !self.gameOver {
                        if playerIdx - 1 >= 0 && (self.gameMap[self.mapIdx][playerIdx - 1] == 1 || self.gameMap[self.mapIdx][playerIdx - 1] == 3 || self.gameMap[self.mapIdx][playerIdx - 1] == 4) && playerIdx % 6 != 0 {
                            
                            if self.gameMap[self.mapIdx][playerIdx - 1] == 3 {
                                self.gameMap[self.mapIdx][playerIdx - 1] = 2
                                self.gameMap[self.mapIdx][playerIdx] = 1
                                if self.tapSound.isPlaying {
                                    self.tapSound.pause()
                                }
                                self.tapSound.currentTime = 0
                                self.tapSound.play()
                                self.winAlert()
                            }
                            else if self.gameMap[self.mapIdx][playerIdx - 1] == 4 {
                                self.gameMap[self.mapIdx][playerIdx - 1] = 2
                                self.gameMap[self.mapIdx][playerIdx] = 1
                                if self.tapSound.isPlaying {
                                    self.tapSound.pause()
                                }
                                self.tapSound.currentTime = 0
                                self.tapSound.play()
                                self.redAlert()
                            }
                            else {
                                self.gameMap[self.mapIdx][playerIdx - 1] = 2
                                self.gameMap[self.mapIdx][playerIdx] = 1
                                if self.tapSound.isPlaying {
                                    self.tapSound.pause()
                                }
                                self.tapSound.currentTime = 0
                                self.tapSound.play()
                            }
                            self.tapSound.play()
                        }
                        
                    } else if self.degrees(mydata.attitude.roll) > self.initialRoll + 15 && !self.gameOver {
                        if playerIdx + 1 <= 47 && (self.gameMap[self.mapIdx][playerIdx + 1] == 1 || self.gameMap[self.mapIdx][playerIdx + 1] == 3 || self.gameMap[self.mapIdx][playerIdx + 1] == 4) && playerIdx % 6 != 5 {
                            
                            if self.gameMap[self.mapIdx][playerIdx + 1] == 3 {
                                self.gameMap[self.mapIdx][playerIdx + 1] = 2
                                self.gameMap[self.mapIdx][playerIdx] = 1
                                if self.tapSound.isPlaying {
                                    self.tapSound.pause()
                                }
                                self.tapSound.currentTime = 0
                                self.tapSound.play()
                                self.winAlert()
                            }
                            else if self.gameMap[self.mapIdx][playerIdx + 1] == 4 {
                                self.gameMap[self.mapIdx][playerIdx + 1] = 2
                                self.gameMap[self.mapIdx][playerIdx] = 1
                                if self.tapSound.isPlaying {
                                    self.tapSound.pause()
                                }
                                self.tapSound.currentTime = 0
                                self.tapSound.play()
                                self.redAlert()
                            }
                            else {
                                self.gameMap[self.mapIdx][playerIdx + 1] = 2
                                self.gameMap[self.mapIdx][playerIdx] = 1
                                if self.tapSound.isPlaying {
                                    self.tapSound.pause()
                                }
                                self.tapSound.currentTime = 0
                                self.tapSound.play()
                            }
                        }
                    }
                }
                
                //print(self.gameMap[self.mapIdx])
            }
        }
    }
    
    func degrees(_ radians: Double) -> Double {
        return 180/Double.pi * radians
    }
    
    func winAlert() {
        gameOver = true
        gameTimer.invalidate()
        let alert = UIAlertController(title: "YOU WON", message: "You're NOT an idiot!!!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK...", comment: "Default action"), style: .default, handler: { _ in
            self.mapIdx += 1
            self.gameOver = false
            self.newLevel = true
            self.seconds = 10
            self.timerLabel.text = "00:\(self.seconds)"
            self.levelLabel.text = "LVL \(self.mapIdx + 1)"
            self.gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(gameViewController.setTimer), userInfo: nil, repeats: true)
            self.gameDelay = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(gameViewController.startReadingMotionData), userInfo: nil, repeats: false)
            self.updateUI()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func redAlert() {
        gameOver = true
        gameTimer.invalidate()
        let alert = UIAlertController(title: "BOOOOOO", message: "No touching red blocks!!!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Sure...", comment: "Default action"), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func updateUI() {
        //print("updateUI")
        for i in 0..<gameMap[self.mapIdx].count{
            if gameMap[self.mapIdx][i] == 0 {
                singleGridView[i].backgroundColor = UIColor.black
            } else if gameMap[self.mapIdx][i] == 1 {
                singleGridView[i].backgroundColor = UIColor.gray
            } else if gameMap[self.mapIdx][i] == 2 {
                singleGridView[i].backgroundColor = UIColor.yellow
            } else if gameMap[self.mapIdx][i] == 3 {
                singleGridView[i].backgroundColor = UIColor.green
            } else if gameMap[self.mapIdx][i] == 4 {
                singleGridView[i].backgroundColor = UIColor.red
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
