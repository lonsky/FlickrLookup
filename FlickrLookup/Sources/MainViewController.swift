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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == self.dynamicType.searchFieldSegueId {
            if let searchFieldController = segue.destinationViewController as? SearchFieldViewController {
                searchFieldController.onPerformLookup = { [weak self] lookupKey in
                    guard let localSelf = self else { return }
                    
                    localSelf.performSegueWithIdentifier(localSelf.dynamicType.searchResultsSegueId, sender: lookupKey)
                }
                searchFieldController.stringValidator = { string in
                    let stringToCheck = string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                    return !stringToCheck.isEmpty
                }
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

