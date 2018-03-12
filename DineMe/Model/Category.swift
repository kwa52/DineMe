//
//  Category.swift
//  DineMe
//
//  Created by Kyle Wang on 2018-03-02.
//  Copyright © 2018 Kyle Wang. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var title : String = ""
    let restaurants = List<Restaurant>()
    
    override static func primaryKey() -> String? {
        return "title"
    }
}
