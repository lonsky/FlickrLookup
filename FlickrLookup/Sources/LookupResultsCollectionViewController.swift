//
//  LookupResultsCollectionViewController.swift
//  FlickrLookup
//
//  Created by Alexander Lonsky on 5/21/16.
//  Copyright © 2016 HomeSweetHome. All rights reserved.
//

import UIKit


class LookupResultsCollectionViewController: UICollectionViewController {
    
    private var photos: [Photo]?
    var lookupKey: String?
    
    private let flickrLookup = FlickrLookup()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let lookupKey = lookupKey {
            flickrLookup.lookup(lookupKey) { [weak self] photos, error in
                self?.photos = photos
                self?.collectionView?.reloadData()
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        flickrLookup.cancel()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos?.count ?? 0
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FlickrPhotoIdentifier", forIndexPath: indexPath)
        cell.backgroundColor = UIColor.greenColor()
        return cell
    }
}

