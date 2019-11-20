//
//  CoreDataAccess.swift
//  Tamagochi
//
//  Created by Benjamin Burkhardt on 20/11/2019.
//  Copyright © 2019 Ragu. All rights reserved.
//

import Foundation
import UIKit
import CoreData

public class PersistentDataManager{
    
    let appDelegate: AppDelegate
    let managedContext: NSManagedObjectContext
    
    let fileManager = FileManager.default
    
    init(){
        self.appDelegate = UIApplication.shared.delegate as! AppDelegate
    
        self.managedContext = appDelegate.persistentContainer.viewContext
        
    }
    
    
    // MARK: - File Access
    func saveImage(image: UIImage, status: ImageType) throws -> String{
        
        if (status != ImageType.food && status != ImageType.water){
            print("Cannot save unhealthy image! \(status)")
            throw TamagotchiError.cannotSaveUnhealthyImage
        }
        
        let name = String(Date().timeIntervalSince1970.description.hashValue)
        print(name)
        
        if let filePath = filePath(forKey: name) {
            do  {
                try image.pngData()!.write(to: filePath, options: .atomic)
            } catch let err {
                print("Saving file resulted in error: ", err)
            }
        }
        
        saveImage(name: name, status: status)
        
        return name
    }
    
    func retrieveImage(forKey: String) -> UIImage? {
        
        if let filePath = filePath(forKey: forKey),
            let fileData = FileManager.default.contents(atPath: filePath.path),
            let image = UIImage(data: fileData) {
            return image
        }
        return nil
    }
    
    
    func filePath(forKey key: String) -> URL? {
        let fileManager = FileManager.default
        guard let documentURL = fileManager.urls(for: .documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first else { return nil }
        
        return documentURL.appendingPathComponent(key + ".png")
    }
    
    
    
    
    // MARK: - CoreData access
    func initHealthStatus(){
        let currentHealthStatusEntity = NSEntityDescription.entity(forEntityName: "HealthStatus", in: managedContext)!
        
        let currentHealthStatus = NSManagedObject(entity: currentHealthStatusEntity, insertInto: managedContext)
        currentHealthStatus.setValue(50, forKey: "hungry")
        currentHealthStatus.setValue(50, forKey: "thirsty")
        // 4 hours ago
        currentHealthStatus.setValue(Date(timeIntervalSinceNow: -(60*60*4)), forKey: "lastPhoto")
        
        do{
            try managedContext.save()
        } catch let error as NSError {
            print("Error while writing CoreData! \(error.userInfo)")
        }
        print("Initialized CoreData HealthStatus entry")
    }
    
    func readHealthStatus() -> [String: Int]{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "HealthStatus")
        
        var healthValues: [String: Int] = [:]
        
        do{
            let result = try managedContext.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                print("thirsty ", data.value(forKey: "thirsty") as! Int)
                healthValues["thirsty"] = data.value(forKey: "thirsty") as? Int
                print("hungry ", data.value(forKey: "hungry") as! Int)
                healthValues["hungry"] = data.value(forKey: "hungry") as? Int
            }
        } catch let error as NSError {
            print("Error while reading CoreData! \(error.userInfo)")
        }
        return healthValues
    }
    
    // TODO decided how much to increase, set date...
    func updateCurrentHealthStatus(){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "HealthStatus")
        fetchRequest.fetchLimit = 1
        
        do{
            let results = try managedContext.fetch(fetchRequest)
            if results.count != 0 {
                let objectToUpdate = results[0] as! NSManagedObject
                // TODO: Do the calcuation depending on the date
                objectToUpdate.setValue(50, forKey: "hungry")
                objectToUpdate.setValue(50, forKey: "thirsty")
            }else{
                throw TamagotchiError.coreDataNotInitialized
            }
            
        } catch {
            print("Could not update CoreData entry! Try to init now... \(error)")
            initHealthStatus()
        }
        
        do{
            let result = try managedContext.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                print(data.value(forKey: "hungry") as! Int16)
            }
        } catch let error as NSError {
            print("Error while reading CoreData! \(error.userInfo)")
        }
    }
    
    
    func saveImage(name: String, status: ImageType){
        let imageTaken = NSEntityDescription.entity(forEntityName: "FoodImage", in: managedContext)!
        
        let imageObject = NSManagedObject(entity: imageTaken, insertInto: managedContext)
        imageObject.setValue(name, forKey: "name")
        imageObject.setValue(Date(), forKey: "date")
        switch status{
        case .food:
            imageObject.setValue("food", forKey: "type")
        case .water:
            imageObject.setValue("water", forKey: "type")
        default:
            print("Could not save image")
            return
        }
        
        do{
            try managedContext.save()
        } catch let error as NSError {
            print("Error while writing image to CoreData! \(error.userInfo)")
        }
        print("Stored image and saved path in CoreData")
    }
    
    func retrieveImages(type: ImageType) -> [StoredImage] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FoodImage")
        
        var images = [StoredImage]()
        
        do{
            let result = try managedContext.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                
                images.append(StoredImage(name: data.value(forKey: "name") as! String, date: data.value(forKey: "date") as! Date, type: data.value(forKey: "type") as! String))
            }
        } catch let error as NSError {
            print("Error while reading CoreData! \(error.userInfo)")
        }
        return images
    }
}
