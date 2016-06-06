//
//  FlickrDataParserJSON.swift
//  FlickrLookup
//
//  Created by Alexander Lonsky on 28/05/16.
//  Copyright © 2016 HomeSweetHome. All rights reserved.
//

import Foundation


struct FlickrDataParserJSON: FlickrDataParser {

    private static let statusOk = "ok"
    
    func parsePhotosLookupResults(data: NSData) -> (photos: [Photo], numberOfPages: Int)? {
        // TODO: make the method throwable to allow caller to process errors
        
        let jsonResults = try? NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions(rawValue: 0))
        guard let results = jsonResults as? NSDictionary else { return nil }
        
        guard let stat = results["stat"] as? String where stat == self.dynamicType.statusOk else { return nil }
        
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
    
    func parsePhotoInfo(data: NSData) -> PhotoInfo? {
        // TODO: make the method throwable to allow caller to process errors
        
        let jsonPhotoInfo = try? NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions(rawValue: 0))
        guard let photoInfo = jsonPhotoInfo as? NSDictionary else { return nil }
        guard let stat = photoInfo["stat"] as? String where stat == self.dynamicType.statusOk else { return nil }

        guard let photoContainer = photoInfo["photo"] as? NSDictionary else { return nil }
        
        guard let ownerContainer = photoContainer["owner"] as? NSDictionary else { return nil }
        let userName = ownerContainer["username"] as? String
        let realName = ownerContainer["realname"] as? String
        
        guard let titleContainer = photoContainer["title"] as? NSDictionary else { return nil }
        let title = titleContainer["_content"] as? String
        
        guard let datesContainer = photoContainer["dates"] as? NSDictionary else { return nil }
        let postedDate = datesContainer["posted"] as? String
        let takenDate = datesContainer["taken"] as? String

        return PhotoInfo(ownerUserName: userName, ownerRealName: realName, title: title, takenDate: takenDate, postedDate: postedDate)
    }
}