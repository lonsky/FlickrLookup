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
    
    private let parser: FlickrDataParser
    
    init(parser: FlickrDataParser) {
        self.parser = parser
    }
    
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
                
                let photos: [Photo]
                if let data = data, let parserResults = self?.parser.parsePhotosLookupResults(data) {
                    photos = parserResults.photos
                    self?.numberOfPages = parserResults.numberOfPages
                } else {
                    photos = []
                }
                
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
}
