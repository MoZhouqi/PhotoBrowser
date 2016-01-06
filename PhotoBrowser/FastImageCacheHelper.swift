//
//  FastImageCacheHelper.swift
//  PhotoBrowser
//
//  Created by Zhouqi Mo on 1/2/15.
//  Copyright (c) 2015 Zhouqi Mo. All rights reserved.
//

import Foundation
import UIKit
import FastImageCache

let KMPhotoImageFormatFamily = "KMPhotoImageFormatFamily"
let KMSmallImageFormatName = "KMSmallImageFormatName"
let KMBigImageFormatName = "KMBigImageFormatName"

var KMSmallImageSize: CGSize {
    let column = UI_USER_INTERFACE_IDIOM() == .Pad ? 4 : 3
    let width = floor((UIScreen.mainScreen().bounds.size.width - CGFloat(column - 1)) / CGFloat(column))
    return CGSize(width: width, height: width)
}

var KMBigImageSize: CGSize {
    let width = UIScreen.mainScreen().bounds.size.width * 2
    return CGSize(width: width, height: width)
}

class FastImageCacheHelper {
    
    class func setUp(delegate: FICImageCacheDelegate) {
        var imageFormats = [AnyObject]()
        let squareImageFormatMaximumCount = 400;
        let smallImageFormat = FICImageFormat(name: KMSmallImageFormatName, family: KMPhotoImageFormatFamily, imageSize: KMSmallImageSize, style: .Style32BitBGRA, maximumCount: squareImageFormatMaximumCount, devices: [.Phone, .Pad], protectionMode: .None)
        imageFormats.append(smallImageFormat)
        
        let bigImageFormat = FICImageFormat(name: KMBigImageFormatName, family: KMPhotoImageFormatFamily, imageSize: KMBigImageSize, style: .Style32BitBGRA, maximumCount: squareImageFormatMaximumCount, devices: [.Phone, .Pad], protectionMode: .None)
        imageFormats.append(bigImageFormat)
        
        let sharedImageCache = FICImageCache.sharedImageCache()
        sharedImageCache.delegate = delegate
        sharedImageCache.setFormats(imageFormats)
    }
}