//
//  User.swift
//  PhotoBrowser
//
//  Created by Zhouqi Mo on 1/2/15.
//  Copyright (c) 2015 Zhouqi Mo. All rights reserved.
//

import Foundation
import CoreData

class User: NSManagedObject {

    @NSManaged var userID: String
    @NSManaged var accessToken: String

}
