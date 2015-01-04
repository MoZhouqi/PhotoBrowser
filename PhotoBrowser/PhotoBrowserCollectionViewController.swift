//
//  PhotoBrowserCollectionViewController.swift
//  PhotoBrowser
//
//  Created by Zhouqi Mo on 12/22/14.
//  Copyright (c) 2014 Zhouqi Mo. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import CoreData

class PhotoBrowserCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var logoutButtonItem: UIBarButtonItem!
    
    let formatName = KMSmallImageFormatName
    var shouldLogin = false
    var user: User? {
        didSet {
            if user != nil {
                handleRefresh()
                hideLogoutButtonItem(false)
                
            } else {
                shouldLogin = true
                hideLogoutButtonItem(true)
            }
        }
    }
    
    var photos = [PhotoInfo]()
    let refreshControl = UIRefreshControl()
    var populatingPhotos = false
    var nextURLRequest: NSURLRequest?
    var coreDataStack: CoreDataStack!
    
    let PhotoBrowserCellIdentifier = "PhotoBrowserCell"
    let PhotoBrowserFooterViewIdentifier = "PhotoBrowserFooterView"
    
    // MARK: Life-cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        var error: NSError?
        if let fetchRequest = coreDataStack.model.fetchRequestTemplateForName("UserFetchRequest") {
            
            let results = coreDataStack.context.executeFetchRequest(fetchRequest,error: &error) as [User]
            user = results.first
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if shouldLogin {
            performSegueWithIdentifier("login", sender: self)
            shouldLogin = false
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func unwindToPhotoBrowser (segue : UIStoryboardSegue) {
        
    }
    
    // MARK: CollectionView
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PhotoBrowserCellIdentifier, forIndexPath: indexPath) as PhotoBrowserCollectionViewCell
        let sharedImageCache = FICImageCache.sharedImageCache()
        cell.imageView.image = nil
        
        let photo = photos[indexPath.row] as PhotoInfo
        if (cell.photoInfo != photo) {
            
            sharedImageCache.cancelImageRetrievalForEntity(cell.photoInfo, withFormatName: formatName)
            
            cell.photoInfo = photo
        }
        
        sharedImageCache.retrieveImageForEntity(photo, withFormatName: formatName, completionBlock: {
            (photoInfo, _, image) -> Void in
            if (photoInfo as PhotoInfo) == cell.photoInfo {
                cell.imageView.image = image
            }
        })
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let footerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: PhotoBrowserFooterViewIdentifier, forIndexPath: indexPath) as PhotoBrowserLoadingCollectionView
        if nextURLRequest == nil {
            footerView.spinner.stopAnimating()
        } else {
            footerView.spinner.startAnimating()
        }
        return footerView
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let photoInfo = photos[indexPath.row]
        performSegueWithIdentifier("show photo", sender: ["photoInfo": photoInfo])
    }
    
    func setupCollectionViewLayout() {
        let layout = UICollectionViewFlowLayout()
        let itemWidth = (view.bounds.size.width - 2) / 3
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        layout.minimumInteritemSpacing = 1.0
        layout.minimumLineSpacing = 1.0
        layout.footerReferenceSize = CGSize(width: collectionView!.bounds.size.width, height: 100.0)
        collectionView!.collectionViewLayout = layout
    }
    
    func setupView() {
        setupCollectionViewLayout()
        collectionView!.registerClass(PhotoBrowserCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: PhotoBrowserCellIdentifier)
        collectionView!.registerClass(PhotoBrowserLoadingCollectionView.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: PhotoBrowserFooterViewIdentifier)
        
        refreshControl.tintColor = UIColor.whiteColor()
        refreshControl.addTarget(self, action: "handleRefresh", forControlEvents: .ValueChanged)
        collectionView!.addSubview(refreshControl)
    }
    
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if (self.nextURLRequest != nil && scrollView.contentOffset.y + view.frame.size.height > scrollView.contentSize.height * 0.8) {
            populatePhotos(self.nextURLRequest!)
        }
    }
    
    func populatePhotos(request:URLRequestConvertible) {
        
        if populatingPhotos {
            return
        }
        
        populatingPhotos = true
        
        Alamofire.request(request).responseJSON() {
            (_ , _, jsonObject, error) in
            
            if (error == nil) {
                //  println(jsonObject)
                let json = JSON(jsonObject!)
                
                if (json["meta"]["code"].intValue  == 200) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                        if let urlString = json["pagination"]["next_url"].URL {
                            self.nextURLRequest = NSURLRequest(URL: urlString)
                        } else {
                            self.nextURLRequest = nil
                        }
                        let photoInfos = json["data"].arrayValue
                            
                            .filter {
                                $0["type"].stringValue == "image"
                            }.map({
                                PhotoInfo(sourceImageURL: $0["images"]["standard_resolution"]["url"].URL!)
                            })
                        
                        let lastItem = self.photos.count
                        self.photos.extend(photoInfos)
                        
                        let indexPaths = (lastItem..<self.photos.count).map { NSIndexPath(forItem: $0, inSection: 0) }
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            self.collectionView!.insertItemsAtIndexPaths(indexPaths)
                        }
                        
                    }
                    
                }
                
            }
            self.populatingPhotos = false
            
        }
    }
    
    func handleRefresh() {
        nextURLRequest = nil
        refreshControl.beginRefreshing()
        self.photos.removeAll(keepCapacity: false)
        self.collectionView!.reloadData()
        refreshControl.endRefreshing()
        if user != nil {
            let urlString = Instagram.Router.PopularPhotos(user!.userID, user!.accessToken)
            populatePhotos(urlString)
        }
    }
    
    func hideLogoutButtonItem(hide: Bool) {
        if hide {
            logoutButtonItem.title = ""
            logoutButtonItem.enabled = false
        } else {
            logoutButtonItem.title = "Logout"
            logoutButtonItem.enabled = true
        }
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "show photo" && segue.destinationViewController.isKindOfClass(PhotoViewerViewController.classForCoder()) {
            let photoViewerViewController = segue.destinationViewController as PhotoViewerViewController
            photoViewerViewController.photoInfo = sender?.valueForKey("photoInfo") as? PhotoInfo
        } else if segue.identifier == "login" && segue.destinationViewController.isKindOfClass(UINavigationController.classForCoder()) {
            let navigationController = segue.destinationViewController as UINavigationController
            if let oauthLoginViewController = navigationController.topViewController as? OauthLoginViewController {
                oauthLoginViewController.coreDataStack = coreDataStack
            }
            
            if self.user != nil {
                coreDataStack.context.deleteObject(user!)
                coreDataStack.saveContext()
                
            }
        }
    }
}
class PhotoBrowserCollectionViewCell: UICollectionViewCell {
    let imageView = UIImageView()
    var photoInfo: PhotoInfo?
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        
        imageView.frame = bounds
        addSubview(imageView)
    }
}

class PhotoBrowserLoadingCollectionView: UICollectionReusableView {
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        spinner.startAnimating()
        spinner.center = self.center
        addSubview(spinner)
    }
}