//
//  ViewController.swift
//  FlickrLookup
//
//  Created by Alexander Lonsky on 5/21/16.
//  Copyright © 2016 HomeSweetHome. All rights reserved.
//

import UIKit


class MainViewController: UIViewController {

    @IBOutlet private var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        containerView.layer.cornerRadius = 5.0
        containerView.layer.masksToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        // TODO:
        return true
    }
    
    // MARK: Actions
    
    @IBAction func lookupButtonDidPress(sender: UIButton) {
        // TODO:
    }
    
    @IBAction func unwindToMainController(segue: UIStoryboardSegue) {
    }
}

