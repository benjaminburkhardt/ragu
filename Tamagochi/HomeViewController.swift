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
    @IBOutlet weak var journeyIcon: UILabel!
    @IBOutlet weak var settingsIcon: UILabel!
    @IBOutlet weak var feedMeButton: UIButton!
    
    // CoreData
    var container: NSPersistentContainer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initializations of colors and fonts
        InitializeOutlets()
        
        // CoreData setup
        container = NSPersistentContainer(name: "DataModel")
        
        guard container != nil else {
            fatalError("This view needs a persistent container.")
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
         performSegue(withIdentifier: "tutorial", sender: nil)
        
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
        UpdateBars()
        
        // TODO: Access Core Data...
        //        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "HealthStatus")
        //        var context = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
        //        print(container.managedObjectModel)
        //        print(fetchRequest)
    }
    
    
    @IBAction func scanButton(_ sender: UIButton) {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera

        present(imagePicker, animated: true, completion: nil)

    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        
        print("Image was taken!")
        
        let inputImage = info[.originalImage] as! UIImage
        
        // go to the FeedbackViewController
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
    
    func InitializeOutlets () {
        settingsIcon.font = UIFont(name: "SFProText-Light", size: 35)
        journeyIcon.font = UIFont(name: "SFProText-Light", size: 35)
        settingsIcon.textColor = GlobalSettings.colors[4]
        journeyIcon.textColor = GlobalSettings.colors[4]

        thirstBar.backgroundColor = GlobalSettings.colors[1]
        hungerBar.backgroundColor = GlobalSettings.colors[3]
        
        
        view.backgroundColor = GlobalSettings.colors[0]
        feedMeButton.backgroundColor = GlobalSettings.colors[4]
    }
    
    // Function to update the bars width depending on hunger and thirst of the Tamagotchi
    func UpdateBars () {
        
        UIView.animate(withDuration: 1, animations: { () -> Void in
            let wii = CGFloat(100)
            self.thirstBar.frame = CGRect(x: self.thirstBar.frame.minX, y: self.thirstBar.frame.minY, width: wii, height: self.thirstBar.frame.height)

        })
        
    }
}
