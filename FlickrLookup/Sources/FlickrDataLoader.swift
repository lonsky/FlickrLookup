//
//  FlickrDataLoader.swift
//  FlickrLookup
//
//  Created by Alexander Lonsky on 5/23/16.
//  Copyright © 2016 HomeSweetHome. All rights reserved.
//

import UIKit


class FlickrDataLoader {
    
    typealias ComletionHandler = ((success: Bool) -> Void)
    
    private let dataLoaderOperationQueue = NSOperationQueue()
    private var thumbnailsQueue = Set<Photo>()

    private let parser: FlickrDataParser
    
    init(parser: FlickrDataParser) {
        self.parser = parser
    }
    
    func loadThumbnail(photo: Photo, completion: ComletionHandler) {
        if thumbnailsQueue.indexOf(photo) == nil {
            thumbnailsQueue.insert(photo)
            dataLoaderOperationQueue.addOperationWithBlock() { [weak self] in
                
                photo.thumbnail = self?.internalLoad(photo)

                self?.thumbnailsQueue.remove(photo)
                
                dispatch_async(dispatch_get_main_queue()) {
                    completion(success: photo.thumbnail != nil)
                }
            }
        } else {
            completion(success: false)
        }
    }

    func load(photo: Photo, completion: ComletionHandler) {
        let downloadPhotoOperation = NSBlockOperation { [ weak self] in
            photo.photo = self?.internalLoad(photo, bigSize: true)
        }
        downloadPhotoOperation.queuePriority = .High
        let downloadPhotoInfoOperation = NSBlockOperation { [ weak self] in
            
            guard let url = FlickrURLFactory.photoInfoURL(photo) else { return }
            guard let photoData = NSData(contentsOfURL: url) else { return }
            
            photo.photoInfo = self?.parser.parsePhotoInfo(photoData)

            dispatch_async(dispatch_get_main_queue()) {
                completion(success: photo.photo != nil)
            }
        }
        downloadPhotoInfoOperation.queuePriority = .High
        
        downloadPhotoInfoOperation.addDependency(downloadPhotoOperation)
        
        dataLoaderOperationQueue.addOperations([downloadPhotoOperation, downloadPhotoInfoOperation], waitUntilFinished: false)
    }
    
    func searchPhotos(text: String, page: Int, itemsPerPage: Int, completion: ((photos: [Photo]?, numberOfPages: Int, error: NSError?) -> Void)) {
        guard let url = FlickrURLFactory.lookupURL(text, page: page, itemsPerPage: itemsPerPage) else {
            completion(photos: nil, numberOfPages: 0, error: nil)
            return
        }
            
        dataLoaderOperationQueue.addOperationWithBlock { [weak self] in
            guard let searchResults = NSData(contentsOfURL: url),
                let parserResults = self?.parser.parsePhotosLookupResults(searchResults) else {
                dispatch_async(dispatch_get_main_queue()){
                    completion(photos: nil, numberOfPages: 0, error: nil)
                }
                return
            }
            
            dispatch_async(dispatch_get_main_queue()){
                completion(photos: parserResults.photos, numberOfPages: parserResults.numberOfPages, error: nil)
            }
        }
    }
    
    func cancelAllLoads() {
        dataLoaderOperationQueue.cancelAllOperations()
        thumbnailsQueue.removeAll()
    }

    private func internalLoad(photo: Photo, bigSize big: Bool = false) -> UIImage? {
        let size = big ? "b" : "m"
        let photoURL = FlickrURLFactory.photoURL(photo, size: size)
        if let imageData = NSData(contentsOfURL: photoURL!) {
            return UIImage(data: imageData)
        }
        return nil
    }
}
