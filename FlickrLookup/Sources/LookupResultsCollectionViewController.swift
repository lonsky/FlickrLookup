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
    private var flickrLookup: FlickrPagingLookup!
    private var flickrPhotosLoader: FlickrDataLoader!
    
    private var fetchingInProgress = false
    private var cellSizeCache: CGSize?
    
    private let placeholderImage = UIImage(named: "placeholder")!
    
    var lookupKey: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let lookupKey = lookupKey else { fatalError("lookupKey key shouldn't be nil here") }
        
        navigationItem.title = lookupKey

        let parser = FlickrDataParserJSON()
        flickrPhotosLoader = FlickrDataLoader(parser: parser)
        flickrLookup = FlickrPagingLookup(dataLoader: flickrPhotosLoader)
        
        flickrLookup.lookup(lookupKey) { [weak self] photos, error in
            
            defer { self?.fetchingInProgress = false }
            
            guard let localSelf = self else { return }
            
            if error == nil {
                
                if photos.isEmpty && localSelf.photos.isEmpty  {
                    // TODO: change aggressive popup alerts to something more gentle. don't show tech details to user
                    localSelf.showAlert("", message: "Couldn't find public photos that contain `\(localSelf.lookupKey)` text. What an opportunity! Upload your photo to Flickr and use the text in the title, description or keywords")
                } else {
                    localSelf.photos.appendContentsOf(photos)
                    localSelf.collectionView?.reloadData()
                }
            } else {
                // TODO: change aggressive popup alerts to something more gentle. don't show tech details to user
                localSelf.showAlert("", message: "Something went wrong while trying to fetch search results. Try to repeat lookup")
            }
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
            flickrPhotosLoader.loadThumbnail(photo) { [weak self] success, error in
                if success {
                    self?.collectionView?.reloadItemsAtIndexPaths([indexPath])
                }
            }
        }
        
        return cell
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if !fetchingInProgress {
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
    
    
    // MARK: - Helpers
 
    private func showAlert(title: String?, message: String) {
        // TODO: move to some Utils
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Cancel) { [weak self] _ in
            self?.dismissViewControllerAnimated(true, completion: nil)
        }
        alertController.addAction(action)
        presentViewController(alertController, animated: true, completion: nil)
    }
}

