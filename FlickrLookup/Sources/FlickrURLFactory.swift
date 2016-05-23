//
//  FlickrURLFactory.swift
//  FlickrLookup
//
//  Created by Alexander Lonsky on 5/22/16.
//  Copyright © 2016 HomeSweetHome. All rights reserved.
//

import Foundation


class FlickrURLFactory {
    private static let apiKey = "babe050614b0895f347495e4e79b606e"
    
    class func lookupURL(text: String, page: Int = 1, itemsPerPage: Int = 100) -> NSURL? {
        guard let escapedText = text.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()) else { return nil }
        
        return NSURL(string: "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&text=\(escapedText)&page=\(page)&per_page=\(itemsPerPage)&format=json&nojsoncallback=1")
    }

    class func photoURL(photo: Photo, size: String = "m") -> NSURL? {
        return NSURL(string: "https://farm\(photo.farm).staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret)_\(size).jpg")!
    }
}
