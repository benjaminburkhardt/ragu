//
//  TutorialViewController.swift
//  Tamagochi
//
//  Created by Alessandro Palermo on 15/11/2019.
//  Copyright © 2019 Ragu. All rights reserved.
//

import Foundation
import UIKit

class TutorialViewController : UIViewController{
    
    @IBAction func exitTutorial(_ sender: UIButton) {
        
        // Closes the tutorial page
        dismiss(animated: true, completion: nil)
        
        // TO_DO: Ask for notifications
    }
}
