//
//  ViewController.swift
//  FlickrLookup
//
//  Created by Alexander Lonsky on 5/21/16.
//  Copyright © 2016 HomeSweetHome. All rights reserved.
//

import UIKit


class MainViewController: UIViewController {

    private static let searchFieldSegueId = "EmbedSearchFieldSegue"
    private static let searchResultsSegueId = "LookupKeywordSegue"
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let segueIdentifier = segue.identifier else { return }
        
        switch(segueIdentifier) {
            case self.dynamicType.searchFieldSegueId: embedSearchFieldController(segue)
            case self.dynamicType.searchResultsSegueId: performSearch(segue, sender: sender)
            default: break
        }
    }
    
    private func embedSearchFieldController(segue: UIStoryboardSegue) {
        if let searchFieldController = segue.destinationViewController as? SearchFieldViewController {
            searchFieldController.onPerformLookup = { [weak self] lookupKey in
                guard let localSelf = self else { return }
                
                localSelf.performSegueWithIdentifier(localSelf.dynamicType.searchResultsSegueId, sender: lookupKey)
            }
            searchFieldController.stringValidator = { string in
                let stringToCheck = string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                return !stringToCheck.isEmpty
            }
        } else {
            fatalError("wrong controller type")
        }
    }
    
    private func performSearch(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let lookupKey = sender as? String else { fatalError("sender has unexpected type") }
        
        let navigationController = segue.destinationViewController as? UINavigationController
        if let lookupController = navigationController?.topViewController as? LookupResultsCollectionViewController {
            lookupController.lookupKey = lookupKey
        }
    }
    
    // MARK: - Actions
    
    @IBAction func handleTap(sender: UITapGestureRecognizer) {
        if sender.state == .Ended {
            view.endEditing(true)
        }
    }

    @IBAction func unwindToMainController(segue: UIStoryboardSegue) {
    }
}

