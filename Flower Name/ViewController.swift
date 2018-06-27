//
//  ViewController.swift
//  Flower Name
//
//  Created by Ula Kuczynska on 6/25/18.
//  Copyright © 2018 Ula Kuczynska. All rights reserved.
//

import UIKit

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
            
        }
    }

    @IBAction func cameraButtonClicked(_ sender: UIBarButtonItem) {
        
        present(imagePicker, animated: true, completion: nil)
    }
    
}

