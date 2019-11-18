//
//  HomeViewController.swift
//  Tamagochi
//
//  Created by Benjamin Burkhardt on 11/11/2019.
//  Copyright © 2019 Ragu. All rights reserved.
//
import UIKit
import CoreData

/*
 This represents the main scene. The Tamagotchi is shown here.
 The user should be triggered to take a picture.
 */
class HomeViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var imagePicker: UIImagePickerController!
    
    // Connection to the Outlet in the Storyboard
    @IBOutlet weak var thirstBar: UIView!
    @IBOutlet weak var hungerBar: UIView!
    @IBOutlet weak var journeyIcon: UIButton!
    @IBOutlet weak var settingsIcon: UIButton!
    @IBOutlet weak var feedMeButton: UIButton!
    
    // CoreData
    var container: NSPersistentContainer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initializations of colors and fonts
        initializeOutlets()
        
        // CoreData setup
        container = NSPersistentContainer(name: "DataModel")
        
        guard container != nil else {
            fatalError("This view needs a persistent container.")
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        // Check if it's the first launch of the app to show the Tutorial
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if launchedBefore  {
            print("Not first launch.")
        } else {
            print("First launch, setting UserDefault.")
            UserDefaults.standard.set(true, forKey: "launchedBefore")
            performSegue(withIdentifier: "tutorial", sender: nil)
        }
        
        // Updating hunger and thirst bars
        updateBars()
        
        // TODO: Access Core Data...
        //        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "HealthStatus")
        //        var context = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
        //        print(container.managedObjectModel)
        //        print(fetchRequest)
    }
    
    
    @IBAction func scanButton(_ sender: UIButton) {
        
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        
        // catch expection in Simulator
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
        }
        else {
            imagePicker.sourceType = .savedPhotosAlbum // or .photoLibrary
        }
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        print("Image captured!")
        let inputImage = info[.originalImage] as! UIImage
        goToFeedbackViewController(inputImage: inputImage)
    }
    
    func goToFeedbackViewController(inputImage: UIImage){
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let feedbackViewController = storyBoard.instantiateViewController(withIdentifier: "feedbackViewController") as! FeedbackViewController
        feedbackViewController.inputImage = inputImage
        self.present(feedbackViewController, animated: true, completion: nil)
        
    }
    
    /// MARK - Prepare stuff for the next ViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nextVC = segue.destination as? FeedbackViewController {
            nextVC.container = container
        }
    }
    
    
    // This is the initizialization of the colors and the fonts of changeble outlets
    // in the Storyboard
    
    func initializeOutlets () {
        settingsIcon.titleLabel?.font = UIFont(name: "SFProText-Light", size: 35)
        journeyIcon.titleLabel?.font = UIFont(name: "SFProText-Light", size: 35)
        
        settingsIcon.setTitleColor(GlobalSettings.colors[4], for: .normal)
        journeyIcon.setTitleColor(GlobalSettings.colors[4], for: .normal)
        
        thirstBar.backgroundColor = GlobalSettings.colors[1]
        hungerBar.backgroundColor = GlobalSettings.colors[3]
        
        view.backgroundColor = GlobalSettings.colors[0]
        feedMeButton.backgroundColor = GlobalSettings.colors[4]
    }
    
    // Function to update the bars width depending on hunger and thirst of the Tamagotchi
    func updateBars () {
        
        UIView.animate(withDuration: 1, animations: { () -> Void in
            let wii = CGFloat(100)
            self.thirstBar.frame = CGRect(x: self.thirstBar.frame.minX, y: self.thirstBar.frame.minY, width: wii, height: self.thirstBar.frame.height)
            
        })
        
    }
    
    
    
    // MARK: - CoreData access
    func initHealthStatus(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
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
    
    func readHealthStatus(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "HealthStatus")
        
        do{
            let result = try managedContext.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                print(data.value(forKey: "hungry") as! Int16)
            }
        } catch let error as NSError {
            print("Error while reading CoreData! \(error.userInfo)")
        }
    }
    
    /// 
    func updateCurrentHealthStatus(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "HealthStatus")
        fetchRequest.fetchLimit = 1
        
        do{
            let results = try managedContext.fetch(fetchRequest)
            if results.count != 0 {
                let objectToUpdate = results[0] as! NSManagedObject
                // TODO: Do the calcuation depending on the date
                objectToUpdate.setValue(100, forKey: "hungry")
                objectToUpdate.setValue(100, forKey: "thirsty")
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
    
    
    enum TamagotchiError: Error{
        case coreDataNotInitialized
    }
    
}
