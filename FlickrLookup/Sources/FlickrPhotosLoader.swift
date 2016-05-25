//
//  FlickrPhotosLoader.swift
//  FlickrLookup
//
//  Created by Alexander Lonsky on 5/23/16.
//  Copyright © 2016 HomeSweetHome. All rights reserved.
//

import UIKit


class FlickrPhotosLoader {
    
    typealias ComletionHandler = ((successfully: Bool) -> Void)
    
    private let photosLoaderOperationQueue = NSOperationQueue()
    private var thumbnailsQueue = Set<Photo>()
    
    func loadThumbnail(photo: Photo, completion: ComletionHandler) {
        if thumbnailsQueue.indexOf(photo) == nil {
            thumbnailsQueue.insert(photo)
            photosLoaderOperationQueue.addOperationWithBlock() { [weak self] in
                var result = false
                let photoURL = FlickrURLFactory.photoURL(photo)
                if let imageData = NSData(contentsOfURL: photoURL!) {
                    photo.thumbnail = UIImage(data: imageData)
                    result = true
                }
                self?.thumbnailsQueue.remove(photo)
                
                dispatch_async(dispatch_get_main_queue()) {
                    completion(successfully: result)
                }
            }
        } else {
            completion(successfully: false)
        }
    }

    func load(photo: Photo, completion: ComletionHandler) {
        photosLoaderOperationQueue.addOperationWithBlock() {
            var result = false
            let photoURL = FlickrURLFactory.photoURL(photo, size: "b")
            if let imageData = NSData(contentsOfURL: photoURL!) {
                photo.photo = UIImage(data: imageData)
                result = true
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                completion(successfully: result)
            }
        }
    }
    
    func cancelAllLoads() {
        photosLoaderOperationQueue.cancelAllOperations()
        thumbnailsQueue.removeAll()
    }
}