//
//  LookupResultsCollectionViewController.swift
//  FlickrLookup
//
//  Created by Alexander Lonsky on 5/21/16.
//  Copyright © 2016 HomeSweetHome. All rights reserved.
//

import UIKit


class LookupResultsCollectionViewController: UICollectionViewController {
    
    private static let cellId = "FlickrPhotoIdentifier"
    
    private var photos = [Photo]()
    private var flickrLookup: FlickrLookup!
    private var flickrPhotosLoader: FlickrPhotosLoader!
    
    private var fetchingInProgress = false
    private var cellSizeCache: CGSize?
    
    private let placeholderImage = UIImage(named: "placeholder")!
    
    var lookupKey: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let lookupKey = lookupKey else { fatalError("lookupKey key shouldn't be nil") }
        
        navigationItem.title = lookupKey

        let parser = FlickrDataParserJSON()
        flickrLookup = FlickrLookup(parser: parser)
        flickrPhotosLoader = FlickrPhotosLoader(parser: parser)
        
        flickrLookup.lookup(lookupKey) { [weak self] photos, error in
            if error == nil {
                self?.photos.appendContentsOf(photos)
                self?.collectionView?.reloadData()
            } else {
                // TODO: process errors
            }
            
            self?.fetchingInProgress = false
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowBigPhotoSegueId" {
            guard let cell = sender as? UICollectionViewCell else { return }
            guard let photoViewController = segue.destinationViewController as? LookupFullscreenPhotoViewController else { return }
            
            photoViewController.photo = photos[cell.tag]
            photoViewController.flickrPhotosLoader = flickrPhotosLoader
            
        } else {
            flickrLookup.cancel()
            flickrPhotosLoader.cancelAllLoads()
        }
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        cellSizeCache = nil
        collectionView?.reloadData()
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
    
    
    // MARK: - UICollectionViewDataSource / UICollectionViewDelegate
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(self.dynamicType.cellId, forIndexPath: indexPath) as! LookupResultsCollectionViewCell
        
        let photo = photos[indexPath.row]
        cell.lookupImage = photo.thumbnail ?? placeholderImage
        cell.tag = indexPath.row
        
        if photo.thumbnail == nil {
            flickrPhotosLoader.loadThumbnail(photo) { successfully in
                if successfully {
                    collectionView.reloadItemsAtIndexPaths([indexPath])
                }
            }
        }
        
        return cell
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if !fetchingInProgress && flickrLookup.canRequestNextPage() {
            let lastScreenYOffset = collectionView!.contentSize.height - 2.0 * collectionView!.bounds.size.height
            if lastScreenYOffset < collectionView!.contentOffset.y {
                fetchingInProgress = flickrLookup.next()
            }
        }
        
        // TODO: it's possible to do cleaning of thumbnails here to reduce memory fingerprint
    }
    
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if let cellSizeCache = cellSizeCache {
            return cellSizeCache
        }
        
        let numberOfItemsPerRow = collectionView.bounds.height > collectionView.bounds.width ? 4 : 6
        
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let sideSize = floor((collectionView.bounds.width - flowLayout.minimumInteritemSpacing * CGFloat(numberOfItemsPerRow - 1)) / CGFloat(numberOfItemsPerRow))

        cellSizeCache = CGSize(width: sideSize, height: sideSize)
        return cellSizeCache!
    }
}

