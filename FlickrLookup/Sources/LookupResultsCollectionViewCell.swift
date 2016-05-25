//
//  LookupResultsCollectionViewCell.swift
//  FlickrLookup
//
//  Created by Alexander Lonsky on 5/22/16.
//  Copyright © 2016 HomeSweetHome. All rights reserved.
//

import Foundation
import UIKit


class LookupResultsCollectionViewCell: UICollectionViewCell {
    @IBOutlet private var lookupImageView: UIImageView!
    
    var lookupImage: UIImage? {
        didSet {
            lookupImageView.image = lookupImage
        }
    }
}
