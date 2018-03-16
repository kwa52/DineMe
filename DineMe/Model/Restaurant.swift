//
//  Restaurant.swift
//  DineMe
//
//  Created by Kyle Wang on 2018-03-02.
//  Copyright © 2018 Kyle Wang. All rights reserved.
//

import Foundation
import RealmSwift

class Restaurant: Object {
    @objc dynamic var name : String?
    @objc dynamic var cuisine : String?
    @objc dynamic var style : String?
    @objc dynamic var address : String?
    @objc dynamic var placeID : String?
    @objc dynamic var isNearby : Bool = false
    @objc dynamic var dateCreated : Date?
    var parent = LinkingObjects(fromType: Category.self, property: "restaurants")    
    
    convenience required init(name: String, cuisine: String, style: String) {
        self.init()
        self.name = name
        self.cuisine = cuisine
        self.style = style
        dateCreated = Date()
    }
}
