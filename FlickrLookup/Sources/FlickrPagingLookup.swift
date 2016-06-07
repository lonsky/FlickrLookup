//
//  FlickrPagingLookup.swift
//  FlickrLookup
//
//  Created by Alexander Lonsky on 5/22/16.
//  Copyright © 2016 HomeSweetHome. All rights reserved.
//

import Foundation
import UIKit


class FlickrPagingLookup {
    typealias ResultsHandler = (([Photo], NSError?) -> Void)
    
    private var lookupText: String?
    private var lookupResults: ResultsHandler?
    private var currentPage: Int = 1
    private var numberOfPages: Int = 0
    private let itemsPerPage: Int = 50
    
    private let dataLoader: FlickrDataLoader
    
    init(dataLoader: FlickrDataLoader) {
        self.dataLoader = dataLoader
    }
    
    func lookup(text: String, results: ResultsHandler) {
        cancel()
        
        lookupResults = results
        lookupText = text
        
        doLookup()
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
        lookupText = nil
        lookupResults = nil
        
        currentPage = 1
        numberOfPages = 0
    }
    
    private func doLookup() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        dataLoader.searchPhotos(lookupText ?? "", page: currentPage, itemsPerPage: itemsPerPage) { [weak self] photos, numberOfPages in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false

            self?.numberOfPages = numberOfPages
            //TODO: error
            self?.lookupResults?(photos ?? [], nil)
        }
    }
    
    private func canRequestNextPage() -> Bool {
        return (currentPage + 1) <= numberOfPages
    }
}
