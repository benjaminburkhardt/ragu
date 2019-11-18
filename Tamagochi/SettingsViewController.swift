//
//  SettingsViewController.swift
//  Tamagochi
//
//  Created by Alessandro Palermo on 18/11/2019.
//  Copyright © 2019 Ragu. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController : UIViewController{
    override func viewDidAppear(_ animated: Bool) {
        self.view.backgroundColor = GlobalSettings.colors[0]
    }
}
