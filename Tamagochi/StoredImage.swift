//
//  StoredImage.swift
//  Tamagochi
//
//  Created by Benjamin Burkhardt on 20/11/2019.
//  Copyright © 2019 Ragu. All rights reserved.
//

import Foundation


class StoredImage {
    var type: ImageType!
    var name: String!
    var date: Date!
    
    
    init(name: String, date: Date, type: String) {
        self.name = name
        self.date = date
        
        switch type{
        case ImageType.food.rawValue:
            self.type = ImageType.food
        case ImageType.water.rawValue:
            self.type = ImageType.food
        case ImageType.unknown.rawValue:
            self.type = ImageType.unknown
        default:
            break
        }
    }
    
}
