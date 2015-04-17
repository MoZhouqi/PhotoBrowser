//
//  PhotoInfo.swift
//  PhotoBrowser
//
//  Created by Zhouqi Mo on 1/2/15.
//  Copyright (c) 2015 Zhouqi Mo. All rights reserved.
//

import Foundation
import Alamofire
import FastImageCache

class PhotoInfo: NSObject, FICEntity {
    var UUID: String {
        let imageName = sourceImageURL.lastPathComponent!
        let UUIDBytes = FICUUIDBytesFromMD5HashOfString(imageName)
        return FICStringWithUUIDBytes(UUIDBytes)
    }
    
    var sourceImageUUID: String {
        return UUID
    }
    
    var sourceImageURL: NSURL
    var request: Alamofire.Request?
    
    init(sourceImageURL: NSURL) {
        self.sourceImageURL = sourceImageURL
        super.init()
    }

    override func isEqual(object: AnyObject?) -> Bool {
        return (object as! PhotoInfo).UUID == self.UUID
    }
    
    func sourceImageURLWithFormatName(formatName: String!) -> NSURL! {
        return sourceImageURL
    }
    
    func drawingBlockForImage(image: UIImage!, withFormatName formatName: String!) -> FICEntityImageDrawingBlock! {
        
        let drawingBlock:FICEntityImageDrawingBlock = {
            (context:CGContextRef!, contextSize:CGSize) in
            var contextBounds = CGRectZero
            contextBounds.size = contextSize
            CGContextClearRect(context, contextBounds)
            
            UIGraphicsPushContext(context)
            image.drawInRect(contextBounds)
            UIGraphicsPopContext()
        }
        return drawingBlock
    }
    
    
}
