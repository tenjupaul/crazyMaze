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
        
        [0,1,0,0,0,3,
         0,5,1,5,4,5,
         0,5,0,5,4,5,
         1,5,0,5,1,5,
         0,5,0,4,0,0,
         0,5,1,0,0,0,
         0,5,0,0,0,0,
         2,5,0,0,0,0]
        
    ]
    
    var mapIdx = 0
    var gameTimer = Timer()
    var blueTimer = Timer()
    var seconds: Int = 10
    var changeBlue: Int = 0
    var newLevel: Bool = true
    var initialPitch: Double = 0.0
    var initialRoll: Double = 0.0
    var gameDelay = Timer()
    var tapSound = AVAudioPlayer()
    var crashSound = AVAudioPlayer()
    var failSound = AVAudioPlayer()
    var successSound = AVAudioPlayer()
    
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
        blueTimer = Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(gameViewController.changeBlueBlocks), userInfo: nil, repeats: true)
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
        do {
            let crashSoundPath = Bundle.main.path(forResource: "crash", ofType: "mp3")
            try crashSound = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: crashSoundPath!) as URL)
            crashSound.volume = 0.7
        } catch {
            //process error
        }
        do {
            let failSoundPath = Bundle.main.path(forResource: "fail", ofType: "mp3")
            try failSound = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: failSoundPath!) as URL)
            failSound.volume = 0.7
        } catch {
            //process error
        }
        do {
            let successSoundPath = Bundle.main.path(forResource: "success", ofType: "mp3")
            try successSound = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: successSoundPath!) as URL)
            successSound.volume = 0.6
        } catch {
            //process error
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        newLevel = true
    }
    @objc func setTimer() {
        //print("start timer")
        seconds -= 1
        timerLabel.text = "00:0\(seconds)"
        if seconds == 0 {
            //timerLabel.text = "GAME OVER"
            gameTimer.invalidate()
            self.failSound.play()
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
    
    @objc func changeBlueBlocks() {
        changeBlue += 1
        for idx in 0..<gameMap[self.mapIdx].count {
            if gameMap[self.mapIdx][idx] == 5 || gameMap[self.mapIdx][idx] == 6 {
                if changeBlue % 10 == 0 || changeBlue % 10 == 1 || changeBlue % 10 == 2 || changeBlue % 10 == 3 || changeBlue % 10 == 4 {
                    gameMap[self.mapIdx][idx] = 6
                }
                else {
                    gameMap[self.mapIdx][idx] = 5
                }
            }
        }
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
                    
                
                    if self.newLevel == true {
                        self.initialRoll = self.degrees(mydata.attitude.roll)
                        self.initialPitch = self.degrees(mydata.attitude.pitch)
                        self.newLevel = false
                    }
                    
                // forward backward
                    if self.degrees(mydata.attitude.pitch) < 0 && !self.gameOver {
                        if playerIdx - 6 >= 0 && (self.gameMap[self.mapIdx][playerIdx - 6] == 1 || self.gameMap[self.mapIdx][playerIdx - 6] == 3 || self.gameMap[self.mapIdx][playerIdx - 6] == 4 || self.gameMap[self.mapIdx][playerIdx - 6] == 5 || self.gameMap[self.mapIdx][playerIdx - 6] == 6) {
                            
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
                            else if self.gameMap[self.mapIdx][playerIdx - 6] == 5 {
                                self.gameMap[self.mapIdx][playerIdx - 6] = 2
                                self.gameMap[self.mapIdx][playerIdx] = 1
                                if self.tapSound.isPlaying {
                                    self.tapSound.pause()
                                }
                                self.tapSound.currentTime = 0
                                self.tapSound.play()
                                self.redAlert()
                            }
                            else if self.gameMap[self.mapIdx][playerIdx - 6] == 6 {
                                self.gameMap[self.mapIdx][playerIdx - 6] = 2
                                if self.changeBlue % 10 == 0 || self.changeBlue % 10 == 1 || self.changeBlue % 10 == 2 || self.changeBlue % 10 == 3 || self.changeBlue % 10 == 4 {
                                    self.gameMap[self.mapIdx][playerIdx] = 5
                                } else {
                                    self.gameMap[self.mapIdx][playerIdx] = 6
                                }
                                if self.tapSound.isPlaying {
                                    self.tapSound.pause()
                                }
                                self.tapSound.currentTime = 0
                                self.tapSound.play()
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
                    } else if self.degrees(mydata.attitude.pitch) > 30 && !self.gameOver {
                        if playerIdx + 6 <= 47 && (self.gameMap[self.mapIdx][playerIdx + 6] == 1 || self.gameMap[self.mapIdx][playerIdx + 6] == 3 || self.gameMap[self.mapIdx][playerIdx + 6] == 4 || self.gameMap[self.mapIdx][playerIdx + 6] == 5 || self.gameMap[self.mapIdx][playerIdx + 6] == 6) {
                            
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
                            else if self.gameMap[self.mapIdx][playerIdx + 6] == 5 {
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
                    }   else if self.degrees(mydata.attitude.roll) < 0 && !self.gameOver {
                        if playerIdx - 1 >= 0 && (self.gameMap[self.mapIdx][playerIdx - 1] == 1 || self.gameMap[self.mapIdx][playerIdx - 1] == 3 || self.gameMap[self.mapIdx][playerIdx - 1] == 4 || self.gameMap[self.mapIdx][playerIdx - 1] == 5 || self.gameMap[self.mapIdx][playerIdx - 1] == 6) && playerIdx % 6 != 0 {
                            
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
                            else if self.gameMap[self.mapIdx][playerIdx - 1] == 5 {
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
                        
                    } else if self.degrees(mydata.attitude.roll) > 30 && !self.gameOver {
                        if playerIdx + 1 <= 47 && (self.gameMap[self.mapIdx][playerIdx + 1] == 1 || self.gameMap[self.mapIdx][playerIdx + 1] == 3 || self.gameMap[self.mapIdx][playerIdx + 1] == 4 || self.gameMap[self.mapIdx][playerIdx + 1] == 5 || self.gameMap[self.mapIdx][playerIdx + 1] == 6) && playerIdx % 6 != 5 {
                            
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
                            else if self.gameMap[self.mapIdx][playerIdx + 1] == 5 {
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
        self.successSound.play()
        let alert = UIAlertController(title: "YOU WON", message: "You're NOT an idiot!!!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("NEXT LEVEL", comment: "Default action"), style: .default, handler: { _ in
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
        self.crashSound.play()
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
            } else if gameMap[self.mapIdx][i] == 5 {
                singleGridView[i].backgroundColor = UIColor.blue
            } else if gameMap[self.mapIdx][i] == 6 {
                singleGridView[i].backgroundColor = UIColor.cyan
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
