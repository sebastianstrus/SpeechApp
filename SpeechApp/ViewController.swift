//
//  ViewController.swift
//  SpeachApp
//
//  Created by Sebastian Strus on 2017-11-05.
//  Copyright © 2017 Sebastian Strus. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController {

    
    @IBOutlet weak var detectTextLabel: UILabel!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var startButton: UIButton!
    
    var screenSize: CGRect!
    var instructionLabel: UILabel!
    var countingLabel: UILabel!
    
    //var timer = Timer()
    var timerForRed = Timer()
    
    var titleLabel: UILabel!
    var blackView: UIView!
    var redLineView: UIImageView!
    var redView: UIView!
    
    let audioEngine = AVAudioEngine()
    //let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    //let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "sv-SE"))
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    
    var counting = 10
    var i = 0
    var alarmActivated = false
    
    var detectedText = "" {
        didSet {
            print("changed!")
            detectTextLabel.text = detectedText
            alarmActivated ? checkStop() : checkStart()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        screenSize = UIScreen.main.bounds
        blackView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
        blackView.backgroundColor = UIColor.black
        self.view.addSubview(blackView)
        
        
        titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: 60))
        titleLabel.center = CGPoint(x: screenSize.width/2, y: 180)
        titleLabel.textAlignment = .center
        titleLabel.text = "Speech Recognizer"
        titleLabel.font = UIFont(name: titleLabel.font.fontName, size: 30)
        titleLabel.textColor = .red
        self.view.addSubview(titleLabel)
        
        //Allows QuickTime Player record the screen, it can't be whole black
        var redlineImage: UIImage = UIImage(named: "redline")!
        redLineView = UIImageView(image: redlineImage)
        redLineView.frame = CGRect(x: 0, y: 250, width: (screenSize.width), height: (100))
        self.view.addSubview(redLineView)
        
        redView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
        redView.backgroundColor = UIColor.red
        
        instructionLabel = UILabel(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: 100))
        instructionLabel.center = CGPoint(x: screenSize.width/2, y: screenSize.height/2 + 180)
        instructionLabel.textAlignment = .center
        instructionLabel.numberOfLines = 0;
        instructionLabel.text = "Say password to \ndeactivate the alarm."
        instructionLabel.font = instructionLabel.font.withSize(30)
        instructionLabel.textColor = UIColor.white
        
        countingLabel = UILabel(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
        countingLabel.center = CGPoint(x: screenSize.width/2, y: screenSize.height/2 + 80)
        countingLabel.textAlignment = .center
        countingLabel.numberOfLines = 0;
        countingLabel.text = "\(counting)"
        countingLabel.font = instructionLabel.font.withSize(100)
        countingLabel.textColor = UIColor.white
        
        //timer = Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(checkStart), userInfo: nil, repeats: true)
        
        
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print(error)
        }
        
        
        guard let myRecognizer = SFSpeechRecognizer() else {
            //
            return
        }
        if !myRecognizer.isAvailable {
            //
            return
        }
        
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { result, error in
            if let result = result {
                let bestString = result.bestTranscription.formattedString
                self.detectedText = bestString
                print("bestString: \(bestString)")
            } else if let error = error {
                print(error)
            }
        })
    }
    
    func nothing() {
        
    }
    @IBAction func startButtonTapped(_ sender: UIButton) {
        self.recordAndRecognizeSpeech()
    }
    
    func recordAndRecognizeSpeech() {
        
    }
    
    
    // must be internal or public.
    @objc func checkStart() {
        if !alarmActivated {
            let string = detectedText.lowercased()
            
            if string.range(of:"hjälp") != nil {
                print("activated!!!")
                activateAlarm()
                detectedText = ""
                self.alarmActivated = true
                //timer.invalidate()
                //timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.checkStop), userInfo: nil, repeats: true)
            }
        }
        i += 1
        print("Checking hjälp: \(i)")
    }
    
    @objc func checkStop() {
        if alarmActivated {
            let string = detectedText
            
            if string.range(of:"123") != nil {
                print("stopped!!!")
                detectedText = ""
                stopAlarm()
                self.alarmActivated = false
                //timer.invalidate()
                //timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.checkStart), userInfo: nil, repeats: true)
            }
        }
        i += 1
        print("Checking 123: \(i)")
    }
    
    func activateAlarm() {

        self.view.addSubview(redView)
        redView.alpha = 0.0
        self.view.addSubview(instructionLabel)
        self.view.addSubview(countingLabel)
        
        timerForRed = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.toggleRedView), userInfo: nil, repeats: true)
        
    }
    
    @objc func toggleRedView() {
        if self.counting > 0 {
            UIView.animate(withDuration: 0.45,
                           animations: {
                            self.redView.alpha = 1.0
                            
                            self.counting -= 1
                            self.countingLabel.text = "\(self.counting)"
                            
            },
                           completion:{ finished in
                            if(finished){
                                UIView.animate(
                                    withDuration: 0.45,
                                    delay: 0.1,
                                    animations: {
                                        self.redView.alpha = 0.0
                                })
                            }
            })
        }
        else {
            self.instructionLabel.text = "Alarm is activated"
            self.instructionLabel.center = CGPoint(x: screenSize.width/2, y: screenSize.height/2)
            self.countingLabel.text = ""
            timerForRed.invalidate()

        }
    }
    

    
        
        
    
    func stopAlarm() {
        timerForRed.invalidate()
        self.redView.removeFromSuperview()
        self.instructionLabel.removeFromSuperview()
        self.countingLabel.removeFromSuperview()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
