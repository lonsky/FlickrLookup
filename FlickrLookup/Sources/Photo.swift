//
//  Photo.swift
//  FlickrLookup
//
//  Created by Alexander Lonsky on 5/22/16.
//  Copyright © 2016 HomeSweetHome. All rights reserved.
//

import Foundation
import UIKit


struct Photo {
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
    
    func sizeToAspectFitPhotoIntoSize(size: CGSize) -> CGSize {
        guard let thumbnail = thumbnail else { return size }
        
        let imageSize = thumbnail.size
        var returnSize = size
        
        let aspectRatio = imageSize.width / imageSize.height
        
        returnSize.height = returnSize.width / aspectRatio
        
        if returnSize.height > size.height {
            returnSize.height = size.height
            returnSize.width = size.height * aspectRatio
        }
        
        return returnSize
    }
}
