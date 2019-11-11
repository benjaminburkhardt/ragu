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
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    var inputImage : UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageViewer.image = inputImage
    }
    @IBOutlet weak var imageViewer: UIImageView!
}
