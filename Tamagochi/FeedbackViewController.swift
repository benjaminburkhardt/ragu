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
    var imageClassification : ImageClassification = ImageClassification()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if inputImage != nil{
            imageViewer.image = inputImage!
            imageClassification.updateClassifications(for: inputImage!)
        }else{
            print("ERROR: No image passed for classification!")
        }
    }
    
    @IBOutlet weak var imageViewer: UIImageView!
}
