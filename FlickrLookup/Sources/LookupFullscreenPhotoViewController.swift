//
//  LookupFullscreenPhotoViewController.swift
//  FlickrLookup
//
//  Created by Alexander Lonsky on 5/25/16.
//  Copyright © 2016 HomeSweetHome. All rights reserved.
//

import UIKit
import Photos


class LookupFullscreenPhotoViewController: UIViewController {

    @IBOutlet private weak var photoImageView: UIImageView!
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var imageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var imageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var imageViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var authorLabel: UILabel!
    @IBOutlet private weak var bottomBarBackgroundView: UIView!
    
    var photo: Photo?
    var flickrPhotosLoader: FlickrDataLoader?
    
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
            flickrPhotosLoader?.load(photo) { [weak self] success, error in
                self?.activityIndicator.stopAnimating()
                if success {
                    self?.applyPhoto(photo)
                } else {
                    //TODO: process error
                    let message = "Can't load photo. Something went wrong :( Please try again."
                    let alertController = UIAlertController(title: "", message: message, preferredStyle: .Alert)
                    let action = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
                    alertController.addAction(action)
                    self?.presentViewController(alertController, animated: true) {
                        self?.dismissViewControllerAnimated(true, completion: nil)
                    }
                }
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateMinZoomScaleForSize(view.bounds.size)
    }
    
    func saveButtonDidPress(sender: UIBarButtonItem) {
        if PHPhotoLibrary.authorizationStatus() == .NotDetermined {
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                if status == .Authorized {
                    self?.doPhotoSaving()
                } else if status != .NotDetermined {
                    dispatch_async(dispatch_get_main_queue()) {
                        self?.navigationItem.rightBarButtonItem = nil
                    }
                }
            }
        } else {
            doPhotoSaving()
        }
    }
    
    private func  doPhotoSaving() {
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({ [weak self] in
                guard let photoToSave = self?.photo?.photo else { return }
    
                let _ = PHAssetChangeRequest.creationRequestForAssetFromImage(photoToSave)
            
        }, completionHandler: { [weak self] success, error in
            dispatch_async(dispatch_get_main_queue()) {
                self?.showPhotoSavingResult(success, error: error)
            }
        })
    }
    
    private func showPhotoSavingResult(success: Bool, error: NSError?) {
        let message = success ? "Photo was successfully saved!": "Can't save photo"
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
        alertController.addAction(action)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    //MARK: - Zooming
    
    private func updateMinZoomScaleForSize(size: CGSize) {
        let widthScale = size.width / photoImageView.bounds.width
        let heightScale = size.height / photoImageView.bounds.height
        let minScale = min(widthScale, heightScale)
        
        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = 1.5
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
        if let author = photo.photoInfo?.author where !author.isEmpty {
            authorLabel.text = "by \(author)"
            bottomBarBackgroundView.hidden = false
        }
        
        let photoLibraryAuthStatus = PHPhotoLibrary.authorizationStatus()
        if photoLibraryAuthStatus != .Denied && photoLibraryAuthStatus != .Restricted {
            let navigationButton = UIBarButtonItem(title: "Save", style: .Plain, target: self, action: #selector(saveButtonDidPress))
            navigationItem.rightBarButtonItem = navigationButton
        }
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
