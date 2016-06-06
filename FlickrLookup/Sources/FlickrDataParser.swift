//
//  FlickrDataParser.swift
//  FlickrLookup
//
//  Created by Alexander Lonsky on 05/06/16.
//  Copyright © 2016 HomeSweetHome. All rights reserved.
//

import Foundation


protocol FlickrDataParser {
    func parsePhotosLookupResults(data: NSData) -> (photos: [Photo], numberOfPages: Int)?
    func parsePhotoInfo(data: NSData) -> PhotoInfo?
}
