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
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var imageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var imageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var imageViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
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
            applyPhoto(photo)
        } else {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            activityIndicator.hidden = false
            activityIndicator.startAnimating()
            flickrPhotosLoader?.load(photo) { [weak self] successfully in
                self?.activityIndicator.stopAnimating()
                if successfully {
                    self?.applyPhoto(photo)
                } else {
                    //TODO: show message
                }
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateMinZoomScaleForSize(view.bounds.size)
    }
    
    
    //MARK: - Zooming
    
    private func updateMinZoomScaleForSize(size: CGSize) {
        let widthScale = size.width / photoImageView.bounds.width
        let heightScale = size.height / photoImageView.bounds.height
        let minScale = min(widthScale, heightScale)
        
        scrollView.minimumZoomScale = minScale
        
        scrollView.zoomScale = minScale
    }
    
    private func updateConstraintsForSize(size: CGSize) {
        
        let yOffset = max(0, round(size.height - photoImageView.frame.height) / 2)
        imageViewTopConstraint.constant = yOffset
        imageViewBottomConstraint.constant = yOffset
        
        let xOffset = max(0, round(size.width - photoImageView.frame.width) / 2)
        imageViewLeadingConstraint.constant = xOffset
        imageViewTrailingConstraint.constant = xOffset
        
        view.layoutIfNeeded()
    }
    

    //MARK: - Helpers
    
    private func applyPhoto(photo: Photo) {
        photoImageView.image = photo.photo
        photoImageView.hidden = false
        photoImageView.sizeToFit()
        navigationItem.title = photo.photoInfo?.title
    }
}


//MARK: - UIScrollViewDelegate

extension LookupFullscreenPhotoViewController: UIScrollViewDelegate {
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return photoImageView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        updateConstraintsForSize(view.bounds.size)
    }
}
