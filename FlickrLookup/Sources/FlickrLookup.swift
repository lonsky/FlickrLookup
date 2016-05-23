//
//  FlickrLookup.swift
//  FlickrLookup
//
//  Created by Alexander Lonsky on 5/22/16.
//  Copyright © 2016 HomeSweetHome. All rights reserved.
//

import Foundation
import UIKit


class FlickrLookup {
    typealias ResultsHandler = (([Photo], NSError?) -> Void)
    
    private var lookupText: String?
    private var lookupResults: ResultsHandler?
    private var currentPage: Int = 1
    private var numberOfPages: Int = 0
    private let itemsPerPage: Int = 50
    
    private var dataTask: NSURLSessionDataTask?
    
    func lookup(text: String, results: ResultsHandler) {
        cancel()
        
        lookupResults = results
        lookupText = text
        
        doLookup()
    }
    
    func canRequestNextPage() -> Bool {
        return (currentPage + 1) <= numberOfPages
    }
    
    func next() -> Bool {
        if !canRequestNextPage() {
            return false
        }
        
        currentPage += 1
        doLookup()
        
        return true
    }

    func cancel() {
        dataTask?.cancel()
        lookupText = nil
        lookupResults = nil
        
        currentPage = 1
        numberOfPages = 0
    }
    
    private func doLookup() {
        if let url = FlickrURLFactory.lookupURL(lookupText ?? "", page: currentPage, itemsPerPage: itemsPerPage) {
            dataTask = NSURLSession.sharedSession().dataTaskWithURL(url) { [weak self] data, response, error in
                let photos = self?.photos(data) ?? []
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                dispatch_async(dispatch_get_main_queue()){
                    self?.lookupResults?(photos, error)
                }
            }
            dataTask?.resume()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        } else {
            // TODO: create error object
            lookupResults?([], nil)
        }
    }
    
    private func photos(data: NSData?) -> [Photo] {
        guard let data = data else { return [] }
        
        let jsonResults = try? NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions(rawValue: 0))
        guard let results = jsonResults as? NSDictionary else { return [] }
                
        if !check(results["stat"] as? String) { return [] }

        guard let photosContainer = results["photos"] as? NSDictionary else { return [] }
        numberOfPages = photosContainer["pages"] as? Int ?? 0
        
        guard let lookupResult = photosContainer["photo"] as? [NSDictionary] else { return [] }
        
        let photos: [Photo] = lookupResult.map { photoData in
            
            let id = photoData["id"] as? String ?? ""
            let farm = photoData["farm"] as? Int ?? 0
            let server = photoData["server"] as? String ?? ""
            let secret = photoData["secret"] as? String ?? ""
            
            let photo = Photo(id: id, secret: secret, farm: String(farm), server: server)
                        
            return photo
            
        }
        
        return photos
    }
        
    private func check(result: String?) -> Bool {
        guard let result = result else { return false }

        // TODO: process errors
        return (result == "ok")
    }
}