//
//  SearchFieldViewController.swift
//  FlickrLookup
//
//  Created by Alexander Lonsky on 5/21/16.
//  Copyright © 2016 HomeSweetHome. All rights reserved.
//

import UIKit


class SearchFieldViewController: UIViewController, UITextFieldDelegate {
    
    var onPerformLookup: ((String) -> Void)?
    var stringValidator: ((String) -> Bool)?
    
    private func keywordEditingDidFinish() {
        let lookupString = lookupTextField.text ?? ""
        if let stringValidator = stringValidator where stringValidator(lookupString) == false {
            return
        }
        
        onPerformLookup?(lookupString)
    }

    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        keywordEditingDidFinish()
        
        return true
    }
    

    // MARK: - Actions
    
    @IBAction func searchButtonDidPress(sender: AnyObject) {
        keywordEditingDidFinish()
    }
    
    
    // MARK: - Outlets
    
    @IBOutlet private weak var lookupTextField: UITextField!
}
