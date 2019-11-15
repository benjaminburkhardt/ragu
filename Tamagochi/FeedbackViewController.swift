//
//  FeedbackViewController.swift
//  Tamagochi
//
//  Created by Benjamin Burkhardt on 11/11/2019.
//  Copyright © 2019 Ragu. All rights reserved.
//

import UIKit
import CoreData

/*
 This represents the feedback scene after taking a photo.
 The sees now if the picture was accepted.
 */

class FeedbackViewController : UIViewController {

    @IBAction func closeFeedback(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    var inputImage : UIImage?
    private var imageClassification : ImageClassification!
    private var status = ImageStatus.unknown
    
    // CoreData
    var container: NSPersistentContainer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = GlobalSettings.colors[0]
        
        imageClassification = ImageClassification(controllerToNotify: self)
        
        if inputImage != nil{
            // view image (maybe not required)
            imageViewer.image = inputImage!
            // run classification asynchroneous
            imageClassification.updateClassifications(for: inputImage!)
        }else{
            print("ERROR: No image passed for classification!")
        }
    }
    
    func updateStatus(status : ImageStatus){
        self.status = status
        
        switch status{
        case .processing:
            statusLabel.text = "Classification..."
            
        case .unknown:
            statusLabel.text = "Unknow status..."
        case .healthy:
            statusLabel.text = "The food is healty!"
        case .unhealthy:
            statusLabel.text = "The food in unhealthy!"
        case .classified:
            statusLabel.text = "Classification finished..."
        case .classificationFailed:
            statusLabel.text = "Classification failed..."
        }
    }
    
    @IBAction func closeButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var imageViewer: UIImageView!
}


// Enums, Helpers

enum ImageStatus : String {
    case unknown
    case processing
    case healthy
    case unhealthy
    case classified
    case classificationFailed
}
