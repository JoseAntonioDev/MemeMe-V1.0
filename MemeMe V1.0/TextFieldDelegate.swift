//
//  TextFieldDelegate.swift
//  MemeMe V1.0
//
//  Created by Jose Antonio Álvarez Vázquez on 9/2/21.
//

import Foundation
import UIKit

class TextFieldDelegate: NSObject, UITextFieldDelegate {
    
    // Set Attributes for text fields
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.strokeWidth: -3.0,
    ]
        
    // Clear the text with the stock message
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (textField.text == "TOP") || (textField.text == "BOTTOM") {
            textField.text = ""
        }
    }
    
    // Hide keyboard when return key is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    
}
