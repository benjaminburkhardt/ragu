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
class HomeViewController: UILoggingViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var imagePicker: UIImagePickerController!
    
    // Connection to the Outlet in the Storyboard
    @IBOutlet weak var thirstBar: UIView!
    @IBOutlet weak var hungerBar: UIView!
    @IBOutlet weak var barBackgroundView: UIView!
    @IBOutlet weak var journeyIcon: UIButton!
    @IBOutlet weak var settingsIcon: UIButton!
    @IBOutlet weak var feedMeButton: UIButton!
    
    // CoreData
    var container: NSPersistentContainer!
    
    let persistentDataManager =  PersistentDataManager()
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        // update data
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        // update outlets
        
        // Updating hunger and thirst bars
        updateBars()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
        // TODO: wait 1 second
        
        // Check if it's the first launch of the app to show the Tutorial
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if launchedBefore  {
            print("Not first launch.")
        } else {
            print("First launch, setting UserDefault.")
            UserDefaults.standard.set(true, forKey: "launchedBefore")
            self.performSegue(withIdentifier: "tutorial", sender: nil)
        }
        }
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
        feedbackViewController.coreDataAccess = persistentDataManager
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
        persistentDataManager.updateCurrentHealthStatus()
        // thirsty level
        UIView.animate(withDuration: 1, animations: { () -> Void in
            let healthStatus = self.persistentDataManager.readHealthStatus()
            let barWidth: CGFloat = self.barBackgroundView.frame.width/100 * CGFloat(healthStatus["thirsty"]!)
            self.thirstBar.frame = CGRect(x: self.thirstBar.frame.minX, y: self.thirstBar.frame.minY, width: barWidth, height: self.thirstBar.frame.height)
        })
        
        // hungry level
        UIView.animate(withDuration: 1, animations: { () -> Void in
            let healthStatus = self.persistentDataManager.readHealthStatus()
            let barWidth: CGFloat = self.barBackgroundView.frame.width/100 * CGFloat(healthStatus["hungry"]!)
            self.hungerBar.frame = CGRect(x: self.hungerBar.frame.minX, y: self.hungerBar.frame.minY, width: barWidth, height: self.hungerBar.frame.height)
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        // release stuff, otherwise it gets killed
        print("Memory warning!!!")
    }
    
}
