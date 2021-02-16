//
//  ViewController.swift
//  MemeMe V1.0
//
//  Created by Jose Antonio Álvarez Vázquez on 3/2/21.
//

import Foundation
import UIKit

class ViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //MARK: Properties
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet var topField: UITextField!
    @IBOutlet var bottomField: UITextField!
    @IBOutlet var startView: UIImageView!
    
    // Top bar:
    @IBOutlet weak var navigationBar: UIToolbar!
    @IBOutlet var shareButton: UIBarButtonItem!
    
    // Bottom bar:
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet var cameraButton: UIBarButtonItem!

    // Create the delegate object
    let textFieldDelegate = TextFieldDelegate()
    
    // Create de meme's struct
    struct Meme {
        var topText: String!
        var bottomText: String!
        var originalImage: UIImage!
        var memedImage: UIImage
    }
    
    var meme: Meme?
    let topText = "TOP"
    let bottomText = "BOTTOM"
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the delegate
        topField.delegate = textFieldDelegate
        bottomField.delegate = textFieldDelegate
        
        // Set the text attributes
        topField.defaultTextAttributes = textFieldDelegate.memeTextAttributes
        bottomField.defaultTextAttributes = textFieldDelegate.memeTextAttributes
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set the initial setup for the app
        initialSetup()
        
        // Disable the camera button if we don't have any cameras availables
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)

        
        subscribeToKeyboardNotifications()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeFromKeyboardNotifications()
    }

    //MARK: Methods
    @IBAction func cancelButton(_ sender: Any) {
        initialSetup()
        topField.resignFirstResponder()
        bottomField.resignFirstResponder()
    }
    
    @IBAction func share(_ sender: Any) {
      
        // Generate the meme's image
        let memedImage = generateMemedImage()
        
        // Pass the image to the activity view controller
        let activityViewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        
        present(activityViewController, animated: true, completion: nil)
        
        activityViewController.completionWithItemsHandler = { (activity: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, activityError: Error?) in
            if completed {
                // Save the image and dismiss the controller
                self.save(memedImage: memedImage)
                activityViewController.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }

    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }

    // Set image picker controller to assign the selected image to the view
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            imagePickerView.image = image
            finishPicker()
        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imagePickerView.image = image
            finishPicker()
        }
    }
    
    // Finish Image picker controller when an image is selected
    func finishPicker() {
        shareButton.isEnabled = (imagePickerView.image != nil)
        startView.isHidden = true
        dismiss(animated: true, completion: nil)
    }
    
    // Initial setup for the app
    func initialSetup() {
        startView.isHidden = false
        topField.text = topText
        topField.textAlignment = .center
        bottomField.text = bottomText
        bottomField.textAlignment = .center
        imagePickerView.image = nil
        shareButton.isEnabled = (imagePickerView.image != nil)
    }
    
    // MARK: Keyboard methods
    @objc func keyboardWillShow(_ notification:Notification) {

        // Move the view to edit the bottom field only
        if (bottomField.isEditing) && (view.frame.origin.y == 0) {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }

    @objc func keyboardWillHide(_ notification:Notification) {

        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {

        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    // This function will add the keyboard observers to the Notification Center
    func subscribeToKeyboardNotifications() {

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    // This function will remove them
    func unsubscribeFromKeyboardNotifications() {

        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: Save the meme
    
    func save(memedImage: UIImage) {
            // Create the meme
            let meme = Meme(topText: topField.text!, bottomText: bottomField.text!, originalImage: imagePickerView.image!, memedImage: memedImage)
            self.meme = meme
    }
    
    // Generate the meme image
    func generateMemedImage() -> UIImage {

        // Hide toolbar and navbar
        navigationBar.isHidden = true
        toolBar.isHidden = true

        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        // Show toolbar and navbar
        navigationBar.isHidden = false
        toolBar.isHidden = false
        
        return memedImage
    }
    
}

