//
//  ViewController.swift
//  DineMe
//
//  Created by Kyle Wang on 2018-03-07.
//  Copyright © 2018 Kyle Wang. All rights reserved.
//

import UIKit
import Eureka
import RealmSwift

class RestaurantFormViewController: FormViewController {
    
    let realm = try! Realm()
    
    var selectedRestaurant : Restaurant? {
        didSet {
            loadForm()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadForm() {
        form +++ Section("Restaurant Info")
            <<< TextRow(){ row in
                row.title = "Name"
                row.placeholder = selectedRestaurant?.name
                row.onChange({ (textRow) in
                    do {
                        try self.realm.write {
                            self.selectedRestaurant!.name = row.value
                        }
                    } catch {
                        print(error)
                    }
                })
            }
            <<< TextRow(){ row in
                row.title = "Cuisine"
                row.placeholder = selectedRestaurant?.cuisine
                row.onChange({ (textRow) in
                    do {
                        try self.realm.write {
                            self.selectedRestaurant!.cuisine = row.value
                        }
                    } catch {
                        print(error)
                    }
                })
            }
            <<< TextRow(){ row in
                row.title = "Style"
                row.placeholder = selectedRestaurant?.style
                row.onChange({ (textRow) in
                    do {
                        try self.realm.write {
                            self.selectedRestaurant!.style = row.value
                        }
                    } catch {
                        print(error)
                    }
                })
            }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
    }
    
}
