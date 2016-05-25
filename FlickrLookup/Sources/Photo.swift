//
//  Photo.swift
//  FlickrLookup
//
//  Created by Alexander Lonsky on 5/22/16.
//  Copyright © 2016 HomeSweetHome. All rights reserved.
//

import UIKit


class Photo: NSObject {
    var thumbnail: UIImage?
    var photo: UIImage?

    let farm: String
    let server: String
    let id: String
    let secret: String
    
    init(id: String, secret: String, farm: String, server: String) {
        self.id = id
        self.secret = secret
        self.farm = farm
        self.server = server
    }
}
