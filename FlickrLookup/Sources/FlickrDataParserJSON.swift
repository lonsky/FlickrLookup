//
//  FlickrDataParserJSON.swift
//  FlickrLookup
//
//  Created by Alexander Lonsky on 28/05/16.
//  Copyright © 2016 HomeSweetHome. All rights reserved.
//

import Foundation


struct FlickrDataParserJSON: FlickrDataParser {

    func parsePhotosLookupResults(data: NSData) -> (photos: [Photo], numberOfPages: Int)? {
        // TODO: make the method throwable
        
        let jsonResults = try? NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions(rawValue: 0))
        guard let results = jsonResults as? NSDictionary else { return nil }
        
        guard let stat = results["stat"] as? String where stat == "ok" else { return nil }
        
        guard let photosContainer = results["photos"] as? NSDictionary else { return nil }
        let numberOfPages = photosContainer["pages"] as? Int ?? 0
        
        guard let lookupResult = photosContainer["photo"] as? [NSDictionary] else { return nil }
        
        let photos: [Photo] = lookupResult.map { photoData in
            
            let id = photoData["id"] as? String ?? ""
            let farm = photoData["farm"] as? Int ?? 0
            let server = photoData["server"] as? String ?? ""
            let secret = photoData["secret"] as? String ?? ""
            
            let photo = Photo(id: id, secret: secret, farm: String(farm), server: server)
            
            return photo
            
        }
        
        return (photos, numberOfPages)
    }
}