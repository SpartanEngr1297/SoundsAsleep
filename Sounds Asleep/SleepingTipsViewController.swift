//
//  SleepingTipsViewController.swift
//  Sounds Asleep
//
//  Created by Brian Lowen on 8/3/17.
//  Copyright © 2017 Brian Lowen. All rights reserved.
//

import UIKit
import AVFoundation

class SleepingTipsViewController: UIViewController {

    @IBOutlet weak var tipTitle: UILabel!
    @IBOutlet weak var tipDetail: UILabel!
    @IBOutlet weak var subViewCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var sleepTipView: UIView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var countDownSecondsLabel: UILabel!
    @IBOutlet weak var circularLoader: KDCircularProgress!
    
    var ding = AVAudioPlayer()
    var timer = Timer()
    var timerActive = false
    var totalSeconds = 60
    var currentSeconds = 0
    var seconds = 60
    var titleCount = 0
    
    var tipArray = [["Deep Breathing", "Spend 60 seconds taking deep breaths. Inhale through your nose, hold the breath for just a moment, and then exhale out your mouth. This will calm your mind, slow your heart rate, and release tension in your body.", "60"], ["Stretching", "Spend 120 seconds stretching. Stretching will relieve some of the tension in your body allowing you to have a more comfortable nights sleep.", "120"], ["Counting Down", "This one is simple but can be effective. Count backwards with the timer down to 0. Focus only on the counting, this can help clear your mind.", "100"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        circularLoader.angle = 0
        startButton.titleLabel?.adjustsFontSizeToFitWidth = true
        tipTitle.text = tipArray[0][0]
        tipDetail.text = tipArray[0][1]
        totalSeconds = Int(tipArray[0][2])!
        seconds = totalSeconds
        
        do {
            // sets up audio player
            ding = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "DingNoise", ofType: "mp3")!))
            ding.prepareToPlay()
            
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func done(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func previous(_ sender: Any) {
        
        clearTimer()
        
        
        // first move view off screen to the left
        subViewCenterConstraint.constant = -800
        
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
            
        }) { (Bool) in
            // when completed hide view and move off screen on right side
            self.sleepTipView.isHidden = true
            self.subViewCenterConstraint.constant = 800
            
            UIView.animate(withDuration: 0.1, animations: {
                self.view.layoutIfNeeded()
            }, completion: { (Bool) in
                // when completed show view and move to the center of screen from right side
                self.sleepTipView.isHidden = false
                self.subViewCenterConstraint.constant = 0
                
                UIView.animate(withDuration: 0.5, animations: {
                    self.view.layoutIfNeeded()
                }, completion: { (Bool) in
                    // once reaching center destination point follow through logic to update the view with desired information
                    self.titleCount -= 1
                    
                    if self.titleCount < 0 {
                        // loop back around if limit is reached
                        self.titleCount = self.tipArray.count - 1
                    }
                    self.tipTitle.text = self.tipArray[self.titleCount][0]
                    self.tipDetail.text = self.tipArray[self.titleCount][1]
                    self.totalSeconds = Int(self.tipArray[self.titleCount][2])!
                    self.seconds = self.totalSeconds
                    self.countDownSecondsLabel.text = String(self.totalSeconds)
                })
            })
        }

    }
    
    @IBAction func next(_ sender: Any) {
        
        clearTimer()
        
        
        // first move view off screen to the right
        subViewCenterConstraint.constant = 800
        
        UIView.animate(withDuration: 0.5, animations: { 
            self.view.layoutIfNeeded()
           
        }) { (Bool) in
            
            // when completed hide view and move off screen on left side
            self.sleepTipView.isHidden = true
            self.subViewCenterConstraint.constant = -800

            UIView.animate(withDuration: 0.1, animations: {
                self.view.layoutIfNeeded()
            }, completion: { (Bool) in
                
                // when completed show view and move to center of screen from left side
                self.sleepTipView.isHidden = false
                self.subViewCenterConstraint.constant = 0
                
                UIView.animate(withDuration: 0.5, animations: { 
                    self.view.layoutIfNeeded()
                }, completion: { (Bool) in
                    
                    // once reaching center destination point follow through logic to update the view with desired information
                    self.titleCount += 1
                    
                    if self.titleCount > self.tipArray.count - 1 {
                        // loop back around if limit is reached
                        self.titleCount = 0
                    }
                    self.tipTitle.text = self.tipArray[self.titleCount][0]
                    self.tipDetail.text = self.tipArray[self.titleCount][1]
                    self.totalSeconds = Int(self.tipArray[self.titleCount][2])!
                    self.seconds = self.totalSeconds
                    self.countDownSecondsLabel.text = String(self.totalSeconds)
                })
            })
        }
    }
  
    @IBAction func startTimerButtonPressed(_ sender: Any) {
        
        if timerActive == false {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(SleepingTipsViewController.updateTime), userInfo: nil, repeats: true)
            
            circularLoader.animate(fromAngle: 0, toAngle: 360, duration: TimeInterval(totalSeconds)) { (Bool) in
                self.circularLoader.animate(fromAngle: self.circularLoader.angle, toAngle: 0, duration: 0.5, completion: nil)
            }
            
            timerActive = true
            startButton.setTitle("Stop", for: .normal)
        } else {
            timer.invalidate()
            timerActive = false
            currentSeconds = 0
            seconds = totalSeconds
            
            countDownSecondsLabel.text = String(totalSeconds)
            startButton.setTitle("Start", for: .normal)
            circularLoader.animate(fromAngle: circularLoader.angle, toAngle: 0, duration: 0.5, completion: nil)
        }
        
    }
    
    func updateTime() {
        if currentSeconds == totalSeconds {
            ding.play()
            timer.invalidate()
            timerActive = false
            currentSeconds = 0
            seconds = totalSeconds
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
                self.countDownSecondsLabel.text = String(Int(self.totalSeconds))
                self.startButton.setTitle("Start", for: .normal)
            })
            
        } else {
            currentSeconds += 1
            seconds -= 1
            
            countDownSecondsLabel.text = String(seconds)
        }
    }
    
    func clearTimer() {
        timer.invalidate()
        timerActive = false
        currentSeconds = 0
        seconds = totalSeconds
        countDownSecondsLabel.text = String(totalSeconds)
        
        circularLoader.layer.removeAllAnimations()
    }
}

// set up storyboard extensions
extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
}
