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
    
    private var currentLookupKey: String?
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == self.dynamicType.searchFieldSegueId {
            if let searchFieldController = segue.destinationViewController as? SearchFieldViewController {
                searchFieldController.onPerformLookup = { [weak self] lookupKey in
                    guard let localSelf = self else { return }
                    
                    localSelf.currentLookupKey = lookupKey
                    localSelf.performSegueWithIdentifier(localSelf.dynamicType.searchResultsSegueId, sender: self)
                }
                searchFieldController.stringValidator = { string in
                    let stringToCheck = string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                    return !stringToCheck.isEmpty
                }
            }
        } else if segue.identifier == self.dynamicType.searchResultsSegueId {
            let navigationController = segue.destinationViewController as? UINavigationController
            if let lookupController = navigationController?.topViewController as? LookupResultsCollectionViewController {
                lookupController.lookupKey = currentLookupKey
            }
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

