//
//  AppDelegate.swift
//  PhotoBrowser
//
//  Created by Zhouqi Mo on 12/22/14.
//  Copyright (c) 2014 Zhouqi Mo. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, FICImageCacheDelegate {
    
    var window: UIWindow?
    lazy var coreDataStack = CoreDataStack()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        FastImageCacheHelper.setUp(self)
        let navController = window!.rootViewController as UINavigationController
        let photoBrowserCollectionViewController = navController.topViewController as PhotoBrowserCollectionViewController
        photoBrowserCollectionViewController.coreDataStack = coreDataStack
        
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        coreDataStack.saveContext()
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        coreDataStack.saveContext()
    }
    
    //MARK: FICImageCacheDelegate
    
    func imageCache(imageCache: FICImageCache!, wantsSourceImageForEntity entity: PhotoInfo!, withFormatName formatName: String!, completionBlock: FICImageRequestCompletionBlock!) {
        let imageURL = entity.sourceImageURLWithFormatName(formatName)
        let request = NSURLRequest(URL: imageURL)
        
        entity.request = Alamofire.request(.GET, request).validate(contentType: ["image/*"]).responseImage() {
            (_, _, image, error) in
            if (error == nil) {
                completionBlock(image)
            }
        }
    }
    
    func imageCache(imageCache: FICImageCache!, cancelImageLoadingForEntity entity: PhotoInfo!, withFormatName formatName: String!) {
        if let request = entity.request {
            request.cancel()
            entity.request = nil
            //println("be canceled:\(entity.UUID)")
        }
    }
    
    func imageCache(imageCache: FICImageCache!, shouldProcessAllFormatsInFamily formatFamily: String!, forEntity entity: FICEntity!) -> Bool {
        return true
    }
    
    func imageCache(imageCache: FICImageCache!, errorDidOccurWithMessage errorMessage: String!) {
        println("errorMessage" + errorMessage)
    }
}

