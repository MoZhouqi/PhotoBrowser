//
//  PhotoViewerViewController.swift
//  PhotoBrowser
//
//  Created by Zhouqi Mo on 1/3/15.
//  Copyright (c) 2015 Zhouqi Mo. All rights reserved.
//

import UIKit

class PhotoViewerViewController: UIViewController, UIScrollViewDelegate {
    
    let scrollView = UIScrollView()
    let imageView = UIImageView()
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    
    var photoInfo: PhotoInfo?
    
    // MARK: Life-Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
    }
    
    func setupView() {
        
        scrollView.frame = view.bounds
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 2.0
        scrollView.zoomScale = 1.0
        view.addSubview(scrollView)
        
        spinner.center = CGPoint(x: view.center.x, y: view.center.y - view.bounds.origin.y / 2.0)
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
        view.addSubview(spinner)
        
        imageView.contentMode = .ScaleAspectFill
        scrollView.addSubview(imageView)
        
        let width = scrollView.frame.size.width
        self.imageView.frame = CGRectMake(0, scrollView.frame.size.height/2 - width/2, width, width)
        
        let sharedImageCache = FICImageCache.sharedImageCache()
        var photo: UIImage?
        let exists = sharedImageCache.retrieveImageForEntity(photoInfo, withFormatName: KMBigImageFormatName, completionBlock: {
            (photoInfo, _, image) -> Void in
            self.imageView.image = image
            self.spinner.stopAnimating()
        })
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "handleDoubleTap:")
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(doubleTapRecognizer)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        centerScrollViewContents()
    }
    
    // MARK: Gesture Recognizers
    
    func handleDoubleTap(recognizer: UITapGestureRecognizer!) {
        let pointInView = recognizer.locationInView(self.imageView)
        self.zoomInZoomOut(pointInView)
    }
    
    // MARK: ScrollView
    
    func scrollViewDidZoom(scrollView: UIScrollView!) {
        self.centerScrollViewContents()
    }
    
    func centerScrollViewContents() {
        let boundsSize = scrollView.frame
        var contentsFrame = self.imageView.frame
        
        if contentsFrame.size.width < boundsSize.width {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
        } else {
            contentsFrame.origin.x = 0.0
        }
        
        if contentsFrame.size.height < boundsSize.height {
            contentsFrame.origin.y = (boundsSize.height - scrollView.scrollIndicatorInsets.top - scrollView.scrollIndicatorInsets.bottom - contentsFrame.size.height) / 2.0
        } else {
            contentsFrame.origin.y = 0.0
        }
        
        self.imageView.frame = contentsFrame
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView!) -> UIView! {
        return self.imageView
    }
    
    func zoomInZoomOut(point: CGPoint!) {
        let newZoomScale = self.scrollView.zoomScale > (self.scrollView.maximumZoomScale/2) ? self.scrollView.minimumZoomScale : self.scrollView.maximumZoomScale
        
        let scrollViewSize = self.scrollView.bounds.size
        
        let width = scrollViewSize.width / newZoomScale
        let height = scrollViewSize.height / newZoomScale
        let x = point.x - (width / 2.0)
        let y = point.y - (height / 2.0)
        
        let rectToZoom = CGRect(x: x, y: y, width: width, height: height)
        
        self.scrollView.zoomToRect(rectToZoom, animated: true)
    }
}
