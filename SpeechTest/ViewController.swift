//
//  ViewController.swift
//  SpeechTest
//
//  Created by Jacob Metcalf on 7/17/19.
//  Copyright © 2019 Jacob Metcalf. All rights reserved.
//

import UIKit
import Speech
import AVKit

class ViewController: UIViewController, SFSpeechRecognizerDelegate {
  
  @IBOutlet weak var recordButton: UIButton!
  @IBOutlet weak var textLabel: UILabel!
  
  var audioEngine: AVAudioEngine!
  var speechRecpgnizer: SFSpeechRecognizer!
  var request: SFSpeechAudioBufferRecognitionRequest!
  var recognitionTask: SFSpeechRecognitionTask?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    audioEngine = AVAudioEngine()
    speechRecpgnizer = SFSpeechRecognizer()
    request = SFSpeechAudioBufferRecognitionRequest()
    SFSpeechRecognizer.requestAuthorization { (status) in
      DispatchQueue.main.async {
        switch status {
        case .authorized:
          break
        case .denied:
          break
        case .notDetermined:
          break
        case .restricted:
          break
        @unknown default:
          break
        }
      }
    }
  }
  
  func startRecording() throws {
    let node = audioEngine.inputNode
    let recordingFormat = node.outputFormat(forBus: 0)
//    if !UserDefaults.standard.bool(forKey: "isInstalled") {
      node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
        self.request.append(buffer)
      }
//      UserDefaults.standard.set(true, forKey: "isInstalled")
//    }
    audioEngine.prepare()
    try audioEngine.start()
    
    recognitionTask = speechRecpgnizer.recognitionTask(with: self.request, resultHandler: { (result, error) in
      guard let result = result else {
        self.cancelRecording()
        return
      }
      self.textLabel.text = result.bestTranscription.formattedString
      if result.isFinal {
        self.textLabel.text = "Final Result: \(result.bestTranscription.formattedString)"
        self.stopRecording()
      }
    })
  }
  
  @IBAction func record(_ sender: UIButton) {
    if sender.titleLabel?.text == "Record" {
      sender.setTitle("Stop", for: .normal)
      do {
        try startRecording()
      } catch {
        print(error.localizedDescription)
      }
    } else {
      sender.setTitle("Record", for: .normal)
      stopRecording()
    }
  }
  
  
  func stopRecording() {
    audioEngine.stop()
    request.endAudio()
  }
  
  func cancelRecording() {
    audioEngine.stop()
    recognitionTask?.cancel()
  }
}

