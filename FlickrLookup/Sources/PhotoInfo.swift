//
//  PhotoInfo.swift
//  FlickrLookup
//
//  Created by Alexander Lonsky on 6/6/16.
//  Copyright © 2016 HomeSweetHome. All rights reserved.
//

import Foundation

struct PhotoInfo {
    let ownerUserName: String?
    let ownerRealName: String?
    let title: String?
    let takenDate: String?
    let postedDate: String?
    //TODO: additional photo info
    
    var author: String {
        if let ownerRealName = ownerRealName {
            return ownerRealName
        } else if let ownerUserName = ownerUserName {
            return ownerUserName
        } else {
            return "Unknown author"
        }
    }
}
