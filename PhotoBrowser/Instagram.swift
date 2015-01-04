//
//  Instagram.swift
//  PhotoBrowser
//
//  Created by Zhouqi Mo on 12/22/14.
//  Copyright (c) 2014 Zhouqi Mo. All rights reserved.
//

import Alamofire
import UIKit

struct Instagram {
    
    enum Router: URLRequestConvertible {
        static let baseURLString = "https://api.instagram.com"
        static let clientID = "cf97d864faf14f90a1557c4b972c990e"
        static let redirectURI = "http://www.example.com/"
        static let clientSecret = "7f1ce6147f924afc92dea31f5354ca06"
        
        case PopularPhotos(String, String)
        case requestOauthCode
        
        static func requestAccessTokenURLStringAndParms(code: String) -> (URLString: String, Params: [String: AnyObject]) {
            let params = ["client_id": Router.clientID, "client_secret": Router.clientSecret, "grant_type": "authorization_code", "redirect_uri": Router.redirectURI, "code": code]
            let pathString = "/oauth/access_token"
            let urlString = Instagram.Router.baseURLString + pathString
            return (urlString, params)
        }
        
        var URLRequest: NSURLRequest {
            let (path: String, parameters: [String: AnyObject]) = {
                switch self {
                case .PopularPhotos (let userID, let accessToken):
                    let params = ["access_token": accessToken]
                    let pathString = "/v1/users/" + userID + "/media/recent"
                    return (pathString, params)
                    
                case .requestOauthCode:
                    let pathString = "/oauth/authorize/?client_id=" + Router.clientID + "&redirect_uri=" + Router.redirectURI + "&response_type=code"
                    return (pathString, nil)
                }
                }()
            
            let BaeseURL = NSURL(string: Router.baseURLString)
            var URLRequest = NSURLRequest(URL: BaeseURL!.URLByAppendingPathComponent(path))
            let encoding = Alamofire.ParameterEncoding.URL
            return encoding.encode(URLRequest, parameters: parameters).0
        }
    }
    
}

extension Alamofire.Request {
    class func imageResponseSerializer() -> Serializer {
        return { request, response, data in
            if data == nil {
                return (nil, nil)
            }
            
            let image = UIImage(data: data!, scale: UIScreen.mainScreen().scale)
            
            return (image, nil)
        }
    }
    
    func responseImage(completionHandler: (NSURLRequest, NSHTTPURLResponse?, UIImage?, NSError?) -> Void) -> Self {
        return response(serializer: Request.imageResponseSerializer(), completionHandler: { (request, response, image, error) in
            completionHandler(request, response, image as? UIImage, error)
        })
    }
}

