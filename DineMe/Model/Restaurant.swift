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
    @objc dynamic var name : String = ""
    @objc dynamic var cuisine : String = ""
    @objc dynamic var style : String = ""
    @objc dynamic var rating : Int = 0
}
