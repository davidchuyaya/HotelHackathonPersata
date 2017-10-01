//
//  VisionVC.swift
//  Hotel
//
//  Created by David Zhang on 9/30/17.
//  Copyright © 2017 David Zhang. All rights reserved.
//

import UIKit

class VisionVC:UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    @IBOutlet weak var cameraButton:UIView!
    @IBOutlet weak var image1:UIImageView!
    @IBOutlet weak var image2:UIImageView!
    @IBOutlet weak var personDelta:UILabel!
    
    let pictureTaker = UIImagePickerController()
    let key = "84d793d630ce42d88fcddfc7afd20cdf"
    let endpoint = "https://westcentralus.api.cognitive.microsoft.com/face/v1.0"
    var picCount = 0
    var personCounts = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        personDelta.isHidden = true
        ViewController.roundAndDropShadow(cameraButton)
        cameraButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cameraButtonPressed(_:))))
    }
    
    @objc
    func cameraButtonPressed(_ sender:UITapGestureRecognizer)
    {
        pictureTaker.sourceType = .camera
        pictureTaker.allowsEditing = false
        pictureTaker.delegate = self
        present(pictureTaker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        pictureTaker.dismiss(animated: true, completion: nil)
        let pic = info[UIImagePickerControllerOriginalImage] as! UIImage
        sendPicture(UIImageJPEGRepresentation(pic, 0.6)!)
        
        picCount += 1
        if picCount == 2 {
            cameraButton.isHidden = true
        }
        if picCount == 1 {
            image1.image = pic
        }
        else if picCount == 2 {
            image2.image = pic
        }
    }
    
    private func sendPicture(_ pic:Data)
    {
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = ["Ocp-Apim-Subscription-Key":key, "Content-Type":"application/octet-stream"]
        let session = URLSession(configuration: config)
        var request = URLRequest(url: URL(string: "\(endpoint)/detect?returnFaceId=true")!)
        request.httpMethod = "POST"
        request.httpBody = pic
        
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            guard data != nil && data?.count != 0 else {
                return
            }
            let json = try! JSONSerialization.jsonObject(with: data!, options: [])
            let jsonArray = json as! [Any]
            
            self.personCounts.append(jsonArray.count)
            
            if self.picCount == 2 {
                let delta = self.personCounts[1] - self.personCounts[0]
                let message:String
                if delta > 0 {
                    message = "\(delta) more person(s)"
                }
                else if delta < 0 {
                    message = "\(-delta) fewer person(s)"
                }
                else {
                    message = "No change"
                }
                self.runAsyncFunc {
                    self.personDelta.text = message
                    self.personDelta.isHidden = false
                }
            }
        }
        dataTask.resume()
    }
    
    private func runAsyncFunc(_ function:@escaping ()->())
    {
        DispatchQueue.main.async {function()}
    }
}
