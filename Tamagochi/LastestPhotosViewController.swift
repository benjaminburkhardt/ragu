//
//  LastestPhotosViewController.swift
//  Tamagochi
//
//  Created by Benjamin Burkhardt on 21/11/2019.
//  Copyright © 2019 Ragu. All rights reserved.
//

import UIKit
import CoreData

/*
 This represents the main scene. The Tamagotchi is shown here.
 The user should be triggered to take a picture.
 */
class LatestPhotosViewController: UITableViewController {
    
    var images: [StoredImage]?
    
    var persistentDataManager: PersistentDataManager?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(persistentDataManager != nil){
            print("Loading stored images")
            images = persistentDataManager!.retrieveImages().reversed()
        }
        
    }
    
    // number of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(images != nil){
            print("Return number of images stored: \(images!.count)")
        return images!.count
        }else{
            images = persistentDataManager!.retrieveImages()
        }
        return images!.count
    
    }
    
    // how does a row look like?
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(images == nil){
            images = persistentDataManager!.retrieveImages()
        }
        
        var cell: UITableViewCell
        if let dequeueCell = tableView.dequeueReusableCell(withIdentifier: "cell") {
            cell = dequeueCell
        } else {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        }
        
        
        cell.backgroundColor = #colorLiteral(red: 0.1254901961, green: 0.8823529412, blue: 0.8196078431, alpha: 1)
        
        var elapsedDays: String = "0"
        if(persistentDataManager != nil){
         elapsedDays = String(persistentDataManager!.daysBetween(start: images![indexPath.row].getDate(), end: Date()))
        }
        
        var daysAgo = "days ago"
        if(elapsedDays == "1"){
            daysAgo = "day ago"
        }
        
        if(elapsedDays == "0"){
            elapsedDays = String(persistentDataManager!.minutesBetween(start: images![indexPath.row].getDate(), end: Date()))
            daysAgo = "minutes ago"
        }

        cell.textLabel?.text = "\(images![indexPath.row].getDescr().capitalizingFirstLetter())"
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        cell.detailTextLabel?.text = "\(elapsedDays) \(daysAgo)"
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 15)
        cell.textLabel?.textColor = .black
        cell.detailTextLabel?.textColor = .gray
        cell.imageView?.image = persistentDataManager?.retrieveImage(forKey: images![indexPath.row].getName())
        return cell
        
    }
    
    
    // Header
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 80))

        let label = UILabel()
        label.frame = CGRect.init(x: 5, y: 5, width: headerView.frame.width-10, height: headerView.frame.height-10)
        label.text = "  History"
        label.font = UIFont.boldSystemFont(ofSize: 35.0)
        label.textColor = .black
        label.textAlignment = .justified
        label.backgroundColor = #colorLiteral(red: 0.1254901961, green: 0.8823529412, blue: 0.8196078431, alpha: 1)

        headerView.addSubview(label)

        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }
}
