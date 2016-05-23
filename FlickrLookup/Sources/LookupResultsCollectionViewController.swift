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
    private let flickrPhotosLoader = FlickrPhotosLoader()
    private var fetchingInProgress = false
    
    private let placeholderImage = UIImage(named: "placeholder")!
    
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
        flickrPhotosLoader.cancelAllLoads()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // release large images
        photos.forEach { $0.photo = nil }
        
        // release invisible thumbnails
        guard let visibleIndexPaths = collectionView?.indexPathsForVisibleItems() where visibleIndexPaths.count > 0 else { return }
        
        let firstIndexPath = visibleIndexPaths.first!
        let lastIndexPath = visibleIndexPaths.last!

        
        for index in 0..<firstIndexPath.row {
            photos[index].thumbnail = nil
        }

        for index in lastIndexPath.row..<photos.count {
            photos[index].thumbnail = nil
        }
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count ?? 0
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FlickrPhotoIdentifier", forIndexPath: indexPath) as! LookupResultsCollectionViewCell
        
        let photo = photos[indexPath.row]
        cell.lookupImage = photo.thumbnail ?? placeholderImage
        
        if photo.thumbnail == nil {
            flickrPhotosLoader.loadThumbnail(photo) { successfully in
                if successfully {
                    collectionView.reloadItemsAtIndexPaths([indexPath])
                }
            }
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let photo = photos[indexPath.row]

        if let thumbnailSize = photo.thumbnailSize {
            return thumbnailSize
        } else if photo.thumbnail != nil {
            return photo.sizeToAspectFitPhotoIntoSize(self.dynamicType.defaultThumbnailSize)
        }

        return placeholderImage.size
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if !fetchingInProgress && flickrLookup.canRequestNextPage() {
            let lastScreenYOffset = collectionView!.contentSize.height - collectionView!.bounds.size.height
            if lastScreenYOffset < collectionView!.contentOffset.y {
                fetchingInProgress = flickrLookup.next()
            }
        }
    }
}

