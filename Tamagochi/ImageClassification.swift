//
//  ImageClassification.swift
//  Tamagochi
//
//  Created by Benjamin Burkhardt on 12/11/2019.
//  Copyright © 2019 Ragu. All rights reserved.
//

import UIKit
import CoreML
import Vision
import ImageIO

class ImageClassification : UIViewController {
    // MARK: - Image Classification
    
    var result : [String] = []
    let controllerToNotify: FeedbackViewController!
    
    
    init(controllerToNotify : FeedbackViewController) {
        self.controllerToNotify = controllerToNotify
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// - Tag: MLModelSetup
    lazy var classificationRequest: VNCoreMLRequest = {
        do {
            let model = try VNCoreMLModel(for: MobileNetV2().model)
            
            let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
                self?.processClassifications(for: request, error: error)
            })
            request.imageCropAndScaleOption = .centerCrop
            return request
        } catch {
            fatalError("Failed to load Vision ML model: \(error)")
        }
    }()
    
    /// - Tag: PerformRequests
    func updateClassifications(for image: UIImage) {
        
        print("Classifying...")
        controllerToNotify.updateStatus(status: ImageStatus.processing)
        
        guard let orientation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue)) else { fatalError("Could not get orientation of image.") }
        guard let ciImage = CIImage(image: image) else { fatalError("Unable to create \(CIImage.self) from \(image).") }
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
                try handler.perform([self.classificationRequest])
                
                
            } catch {
                /*
                 This handler catches general image processing errors. The `classificationRequest`'s
                 completion handler `processClassifications(_:error:)` catches errors specific
                 to processing that request.
                 */
                print("Failed to perform classification.\n\(error.localizedDescription)")
            }
        }
    }
    
    /// Updates the UI with the results of the classification.
    /// - Tag: ProcessClassifications
    func processClassifications(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let results = request.results else {
                print("Unable to classify image.\n\(error!.localizedDescription)")
                return
            }
            // The `results` will always be `VNClassificationObservation`s, as specified by the Core ML model in this project.
            let classifications = results as! [VNClassificationObservation]
            
            if classifications.isEmpty {
                print("Nothing recognized.")
                self.controllerToNotify.updateStatus(status: ImageStatus.classificationFailed)
            } else {
                // Display top classifications ranked by confidence in the UI.
                let topXToCheck = 3
                let topClassifications = classifications.prefix(topXToCheck)
                var recognized = [String]()
                var confidence : Float = 0
                for classification in topClassifications{
                    recognized = recognized + String(classification.identifier).components(separatedBy: ", ")
                    
                    if confidence==0{
                        confidence = classification.confidence
                    }
                }
                
                print(recognized)
                print("Highest confidence: " , confidence)
                
                self.result = recognized
                self.controllerToNotify.updateStatus(status: ImageStatus.classified)
                
                // TODO: Check a DB if this is healthy or not...ù
                //
                //
                //
                
                // IF is Image of healthy Food
                // Start animation in FeedbackViewController
                 self.controllerToNotify.healthyImageRecognized()
                
                // ELSE IF is Image of unhealthy Food
                //self.controllerToNotify.unhealthyImageRecognized()
                
                // ELSE IF Image is not recognized
                //self.controllerToNotify.imageNotRecognized()
            }
        }
    }
}
