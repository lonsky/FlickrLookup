//
//  LookupFullscreenPhotoViewController.swift
//  FlickrLookup
//
//  Created by Alexander Lonsky on 5/25/16.
//  Copyright © 2016 HomeSweetHome. All rights reserved.
//

import UIKit

class LookupFullscreenPhotoViewController: UIViewController {

    @IBOutlet private weak var photoImageView: UIImageView!
    
    var photo: Photo?
    var flickrPhotosLoader: FlickrPhotosLoader?
    
    init(photo: Photo) {
        self.photo = photo
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let photo = photo else { return }
        if photo.photo != nil {
            photoImageView.image = photo.photo
        } else {
            flickrPhotosLoader?.load(photo) { [weak self] successfully in
                if successfully {
                    self?.photoImageView.image = photo.photo
                }
            }
        }
    }
}
