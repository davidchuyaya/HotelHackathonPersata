//
//  ViewController.swift
//  Hotel
//
//  Created by David Zhang on 9/30/17.
//  Copyright © 2017 David Zhang. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SFSpeechRecognizerDelegate {
    @IBOutlet weak var microphoneButton: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    let audioEngine = AVAudioEngine()
    let speechRecognizer = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask:SFSpeechRecognitionTask?
    var listening = false
    var bestResult:String!
    
    var data = [("towels", UIImage(named: "Towel"), 0), ("shampoos", UIImage(named: "Shampoo"), 0), ("fruits", UIImage(named: "Apple"), 0), ("toothbrushes", UIImage(named: "Toothbrush"), 0)]
    var behaviors = [String]()
    let nums = ["zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ViewController.roundAndDropShadow(microphoneButton)
        microphoneButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onMicClick(sender:))))
    }
    
    static func roundAndDropShadow(_ view:UIView)
    {
        view.layer.cornerRadius = view.frame.width / 2
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = CGSize(width: 2, height: 2)
        view.layer.shadowRadius = 2
    }
    
    @objc
    func onMicClick(sender:UITapGestureRecognizer)
    {
        if !listening {
            microphoneButton.backgroundColor = UIColor.red
            startListening()
        }
        else {
            microphoneButton.backgroundColor = UIColor.green
            stopListening()
        }
        
        listening = !listening
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func startListening()
    {
        let recordingFormat = audioEngine.inputNode.outputFormat(forBus: 0)
        audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat, block: {
            buffer, _ in
            self.request.append(buffer)
        })
        guard speechRecognizer != nil else {
            print("speechRecognizer is nil")
            return
        }
        guard speechRecognizer!.isAvailable else {
            print("speechRecognizer is unavailable")
            return
        }
        
        recognitionTask = speechRecognizer!.recognitionTask(with: request, resultHandler: {
            result, _ in
            guard result != nil else {
                return
            }
            
            if let recording = result?.bestTranscription.formattedString {
                self.bestResult = recording.lowercased()
                print(self.bestResult)
            }
        })
        
        audioEngine.prepare()
        try! audioEngine.start()
    }
    
    private func stopListening()
    {
        self.audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        request.endAudio()
        self.recognitionTask?.cancel()
        self.recognitionTask = nil
        
        let resultParts = bestResult.components(separatedBy: " ")
        for i in 0..<data.count
        {
            let name = data[i].0
            if resultParts.contains(name.lowercased())
            {
                for j in 0..<nums.count
                {
                    let num = nums[j]
                    if resultParts.contains(num)
                    {
                        data[i].2 = j
                        tableView.reloadRows(at: [IndexPath(row:i, section:0)], with: .automatic)
                        return
                    }
                }
            }
        }
        
        //nothing matched, must be behavioral
        behaviors.append(bestResult)
        tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return section == 0 ? data.count : behaviors.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return section == 0 ? "Items" : "Behaviors"
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if indexPath.section == 0
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! Cell
            cell.name.text = data[indexPath.row].0
            cell.itemImage.image = data[indexPath.row].1
            cell.count.text = String(data[indexPath.row].2)
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "behavior", for: indexPath)
            cell.textLabel?.text = behaviors[indexPath.row]
            return cell
        }
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return indexPath.section == 1
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        guard editingStyle == .delete else {
            return
        }
        
        behaviors.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
}

