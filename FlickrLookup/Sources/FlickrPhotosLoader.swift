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
                
                photo.thumbnail = self?.internalLoad(photo)

                self?.thumbnailsQueue.remove(photo)
                
                dispatch_async(dispatch_get_main_queue()) {
                    completion(successfully: photo.thumbnail != nil)
                }
            }
        } else {
            completion(successfully: false)
        }
    }

    func load(photo: Photo, completion: ComletionHandler) {
        photosLoaderOperationQueue.addOperationWithBlock() { [weak self] in
            photo.photo = self?.internalLoad(photo, bigSize: true)
            
            dispatch_async(dispatch_get_main_queue()) {
                completion(successfully: photo.photo != nil)
            }
        }
    }
    
    private func internalLoad(photo: Photo, bigSize big: Bool = false) -> UIImage? {
        let size = big ? "b" : "m"
        let photoURL = FlickrURLFactory.photoURL(photo, size: size)
        if let imageData = NSData(contentsOfURL: photoURL!) {
            return UIImage(data: imageData)
        }
        return nil
    }
    
    func cancelAllLoads() {
        photosLoaderOperationQueue.cancelAllOperations()
        thumbnailsQueue.removeAll()
    }
}