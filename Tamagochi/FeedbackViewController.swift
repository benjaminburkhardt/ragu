//
//  FeedbackViewController.swift
//  Tamagochi
//
//  Created by Benjamin Burkhardt on 11/11/2019.
//  Copyright © 2019 Ragu. All rights reserved.
//

import UIKit

/*
 This represents the feedback scene after taking a photo.
 The sees now if the picture was accepted.
 */

class FeedbackViewController : UIViewController {
    
    var inputImage : UIImage?
    private var imageClassification : ImageClassification!
    private var status = ImageStatus.unknown
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
