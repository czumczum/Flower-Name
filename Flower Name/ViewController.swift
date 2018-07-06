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
import SwiftyJSON
import Alamofire
import SDWebImage

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageViewController: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    let imagePicker = UIImagePickerController()
    let wikipediaURL = "https://en.wikipedia.org/w/api.php"
    
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
            guard let flowerName = observations.first?.identifier.capitalized else {
                fatalError("There's no flower name!")
            }
            self.navigationItem.title = flowerName
            self.requestInfo(with: flowerName)
        }

        let handler = VNImageRequestHandler(ciImage: ciimage)
        
        do {
            try handler.perform([request])
        }
        catch {
            print(error)
        }
    }
    
    func requestInfo(with flowerName: String) {
        let parameters: [String:String] = [
            "format" : "json",
            "action" : "query",
            "prop" : "extracts|pageimages",
            "exintro" : "",
            "explaintext" : "",
            "titles" : flowerName,
            "indexpageids" : "",
            "redirects" : "1",
            "pithumbsize" : "500"
        ]
        
        Alamofire.request(wikipediaURL, method: .get, parameters: parameters).responseJSON { (response) in
            if response.result.isSuccess {
                let flowerJSON : JSON = JSON(response.result.value!)
                let pageId = (flowerJSON["query"]["pages"].dictionary?.keys.first!)!
                
                print(flowerJSON)
                let flowerDescription = flowerJSON["query"]["pages"][pageId]["extract"]
                let flowerImageUrl = flowerJSON["query"]["pages"][pageId]["thumbnail"]["source"].stringValue
                
                self.descriptionLabel.text = flowerDescription.stringValue
                self.imageViewController.sd_setImage(with: URL(string: flowerImageUrl ), completed: nil)
                
            
            }
        }
    }
    
}

