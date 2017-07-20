//
//  ViewController.swift
//  Sounds Asleep
//
//  Created by Brian Lowen on 5/8/17.
//  Copyright © 2017 Brian Lowen. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var setTimerButton: UIButton!
    @IBOutlet weak var cdTimerConstraint: NSLayoutConstraint!
    @IBOutlet weak var backgroundButton: UIButton!
    @IBOutlet weak var countDownTimerPicker: UIDatePicker!
    @IBOutlet weak var countDownTimerLabel: UILabel!
    
    let pauseImage = UIImage(named: "PauseWhite.png")
    let playImage = UIImage(named: "WhitePlay.png")
    var whiteNoise = AVAudioPlayer()
    var time = 0
    var cdTimer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        countDownTimerPicker.backgroundColor = UIColor.white
        countDownTimerPicker.alpha = 0.8
        
        setTimerButton.layer.borderWidth = 3
        setTimerButton.layer.cornerRadius = 10
        setTimerButton.layer.borderColor = UIColor.darkGray.cgColor
        setTimerButton.backgroundColor = UIColor.darkGray
        setTimerButton.alpha = 0.7
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.updateTime()
        }
        
        do {
            // sets up audio player
            whiteNoise = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "FanNoise", ofType: "m4a")!))
            whiteNoise.prepareToPlay()
            
            // play indefinitely
            whiteNoise.numberOfLoops = -1
            
            // sets up background play
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setCategory(AVAudioSessionCategoryPlayback)
            }
            catch {
                print(error)
            }
        }
        catch {
            print(error)
        }
        
        
    }
    
    override var prefersStatusBarHidden: Bool {
        // hide the status bar
        return true
    }
    
    @IBAction func playSound(_ sender: Any) {
        
        // change button image on click
        if playButton.currentImage == pauseImage {
            playButton.setImage(playImage, for: UIControlState.normal)
            
            if whiteNoise.isPlaying {
                whiteNoise.pause()
            }
            
        } else {
            playButton.setImage(pauseImage, for: UIControlState.normal)
            whiteNoise.play()
        }
        
    }
    @IBAction func setTimerButton(_ sender: Any) {
        
        if setTimerButton.title(for: .normal) == "Set Timer"{
        
            // get picker out
            cdTimerConstraint.constant = 0
        
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
                self.backgroundButton.alpha = 0.6
            }
            
            setTimerButton.setTitle("Clear Timer", for: .normal)
            
        }
        else {
            
            countDownTimerLabel.text = "00:00:00"
            cdTimer.invalidate()
        
            setTimerButton.setTitle("Set Timer", for: .normal)

        }
        
        
    }
    
    @IBAction func pickerDoneButton(_ sender: Any) {
        
        // prevent multiple timers from being created
        if cdTimer != nil {
            cdTimer.invalidate()
        }
        
        // put picker away
        cdTimerConstraint.constant = -300
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
            self.backgroundButton.alpha = 0
        }
        
        time = Int(countDownTimerPicker.countDownDuration)
        
        cdTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector (ViewController.decreaseTime), userInfo: nil, repeats: true)
        
    }
    func updateTime(){
        
        timeLabel.text = DateFormatter.localizedString(from: Date(), dateStyle: DateFormatter.Style.none, timeStyle: DateFormatter.Style.short)
        
    }
    
    func decreaseTime(){
        if time > 0{
            time -= 1
        } else {
            cdTimer.invalidate()
            whiteNoise.stop()
            playButton.setImage(playImage, for: UIControlState.normal)
            setTimerButton.setTitle("Set Timer", for: .normal)
            
        }
        
        updateCountDownTimer()
    }
    
    func updateCountDownTimer(){
        let seconds = String(time % 60)
        let minutes = String((time / 60) % 60)
        let hours = String(time / 3600)
    
        let timeStr = "\(hours):\(minutes):\(seconds)"
        
        let timerFormatter = DateFormatter()
        timerFormatter.dateFormat = "KK:mm:ss"
        
        let countDownTimer = timerFormatter.date(from: timeStr)
        
        let cdtimer = timerFormatter.string(from: countDownTimer!)
        
        countDownTimerLabel.text = cdtimer
        
    }
    

}

