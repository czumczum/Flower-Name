//
//  ViewController.swift
//  Flower Name
//
//  Created by Ula Kuczynska on 6/25/18.
//  Copyright © 2018 Ula Kuczynska. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageViewController: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary //TODO: change to .camera on device
        imagePicker.allowsEditing = false
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            imageViewController.image = image
            imagePicker.dismiss(animated: true, completion: nil)
            
            guard let ciImage = CIImage(image: image) else {
                fatalError("Image cannot be transformed into CIImage")
            }
            
            detect(with: ciImage)
            
        }
    }

    @IBAction func cameraButtonClicked(_ sender: UIBarButtonItem) {
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func detect(with ciimage: CIImage) {
        
        guard let model = try? VNCoreMLModel(for: Oxford102().model) else {
            fatalError("Model cannot be incorporated")
        }
        let request = VNCoreMLRequest(model: model) { (request,error) in
            guard let observations = request.results as? [VNClassificationObservation] else {
                fatalError("There's no observations")
            }
            print(observations.first)
        }

        let handler = VNImageRequestHandler(ciImage: ciimage)
        
        do {
            try handler.perform([request])
        }
        catch {
            print(error)
        }
    }
    
}

