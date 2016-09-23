//
//  ImageInputSelectorViewController.swift
//  RockDock
//
//  Created by Stephen Buck on 9/10/16.
//  Copyright © 2016 Stephen Buck. All rights reserved.
//

import UIKit

class ImageInputSelectorViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //Mark: Properties
    @IBOutlet weak var cameraButton: UIButton!
    
    @IBOutlet weak var libraryButton: UIButton!
    
     var imageInputMethod: UIImagePickerControllerSourceType?
    
    @IBOutlet weak var savedImagesButton: UIButton!
    //MARK: Navigation
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("in prepare for seque from ImageInputSelect ")
        if !UIImagePickerController.isSourceTypeAvailable(.camera){
            print("no camera")
            cameraButton.isEnabled = false
            
        }
        
        if !UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            print("no library")
            libraryButton.isHidden = true
            
        }
        
        if !UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            print("no album")
            savedImagesButton.isHidden = true
        }
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           }
    
    
    
    //MARK: Actions
    @IBAction func cameraSelected(_ sender: UIButton) {
        imageInputMethod = UIImagePickerControllerSourceType.camera
        print("imageInputMethod: \(imageInputMethod!.rawValue)")
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func librarySelected(_ sender: UIButton) {
        imageInputMethod = UIImagePickerControllerSourceType.photoLibrary
        print("imageInputMethod: \(imageInputMethod!.rawValue)")
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func savedImagesSelected(_ sender: UIButton) {
        imageInputMethod = UIImagePickerControllerSourceType.savedPhotosAlbum
        print("imageInputMethod: \(imageInputMethod!.rawValue)")
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelSelected(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)
    }
    
}
