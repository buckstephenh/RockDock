//
//  RockViewController.swift
//  RockDock
//
//  Created by Stephen Buck on 8/27/16.
//  Copyright © 2016 Stephen Buck. All rights reserved.
//

import UIKit


class RockViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: Properties
    
    @IBOutlet weak var rockName: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var ratingControl: RatingControl!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var tradeSwitch: UISwitch!
    @IBOutlet weak var tradeLabel: UILabel!
    @IBOutlet weak var Action: UIBarButtonItem!
    
    

    /*
     Rock is either passed by `RockTableViewController` in `prepareForSegue(_:sender:)`
     or constructed as part of adding a new rock.
     */
    var rock: Rock?
    var imageInputMethod: UIImagePickerControllerSourceType?
    
    //MARK: View Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //Handle the text field input through delegate callbacks
        rockName.delegate = self
        
        // Set up views if editing an existing Rock.
        if let rock = rock {
            navigationItem.title = rock.name
            rockName.text   = rock.name
            imageView.image = rock.photo
            ratingControl.rating = rock.rating
            ratingControl.updateButtonSelectionStates()
        }
        
        // Enable the Save button only if the text field has a valid Rock name.
        checkValidRockName()
        
    }
    
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        saveButton.isEnabled = false
    }

    
    func checkValidRockName() {
        // Disable the Save button if the text field is empty.
        let text = rockName.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
    
    @available(iOS 10.0, *)
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        checkValidRockName()
        navigationItem.title = textField.text
    }
    
    
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
        } else{
            print("Something went wrong")
        }
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
    
    
    // MARK: Navigation
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
        let isPresentingInAddRockMode = presentingViewController is UINavigationController
        
        if isPresentingInAddRockMode {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController!.popViewController(animated: true)
        }
    }
    
    
    // This method lets you configure a view controller before it's presented.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("In prepare for seque in RockViewController")
        if saveButton === sender as? UIBarButtonItem {
            let name = rockName.text ?? ""
            let photo = imageView.image
            let rating = ratingControl.rating
            let owner = User.getUser().uuid
            
            // Set the rock to be passed to RockTableViewController after the unwind segue.
            rock = Rock(name: name, photo: photo, rating: rating, owner:owner)
        }
        
    }
    
    @IBAction func unwindToViewRock(sender: UIStoryboardSegue) {
        
        if let sourceViewController = sender.source as? ImageInputSelectorViewController, let imageInputMethod = sourceViewController.imageInputMethod {
            
            selectImageFromPhotoLibrary(sourceType: imageInputMethod)
        }
    }
    
    
    
    
    //MARK: Actions
    func selectImageFromPhotoLibrary(sourceType: UIImagePickerControllerSourceType) {
        // Hide the keyboard.
        rockName.resignFirstResponder()
        
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()

        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
 
        imagePickerController.sourceType = sourceType
        
        // get image
        present(imagePickerController, animated: true, completion: nil)
        
        
       
    }
    
    
    
    
        
}

