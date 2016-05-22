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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.7)
        
        layer.cornerRadius = 2.0
        layer.masksToBounds = true
    }
    
    var lookupImage: UIImage? {
        didSet {
            lookupImageView.image = lookupImage
        }
    }
}
