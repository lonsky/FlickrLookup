//
//  LookupResultsCollectionViewController.swift
//  FlickrLookup
//
//  Created by Alexander Lonsky on 5/21/16.
//  Copyright © 2016 HomeSweetHome. All rights reserved.
//

import UIKit


class LookupResultsCollectionViewController: UICollectionViewController {
    
    private static let defaultThumbnailSize = CGSize(width: 100.0, height: 100.0)

    private var photos = [Photo]()
    private let flickrLookup = FlickrLookup()
    private var fetchingInProgress = false
    
    var lookupKey: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let lookupKey = lookupKey {
            navigationItem.title = lookupKey
            flickrLookup.lookup(lookupKey) { [weak self] photos, error in
                // TODO: process errors
                self?.photos.appendContentsOf(photos)
                self?.collectionView?.reloadData()
                
                self?.fetchingInProgress = false
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        flickrLookup.cancel()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        // TODO: release large images
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count ?? 0
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FlickrPhotoIdentifier", forIndexPath: indexPath) as! LookupResultsCollectionViewCell
        
        let photo = photos[indexPath.row]
        cell.lookupImage = photo.thumbnail
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let photo = photos[indexPath.row]
        
        return photo.sizeToAspectFitPhotoIntoSize(self.dynamicType.defaultThumbnailSize)
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if !fetchingInProgress && flickrLookup.canRequestNextPage() {
            let lastScreenYOffset = collectionView!.contentSize.height - collectionView!.bounds.size.height
            if lastScreenYOffset < collectionView!.contentOffset.y {
                fetchingInProgress = flickrLookup.next()
                
                // TODO: remove
                NSLog("Next: lastScreenYOffset(\(lastScreenYOffset)) <= collectionView!.contentOffset.y(\(collectionView!.contentOffset.y)) ")
            }
        }
    }
}

