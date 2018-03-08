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
import SCLAlertView

class RestaurantFormViewController: FormViewController {
    
    let realm = try! Realm()
    
    var nameInput: String?
    var cuisineInput: String?
    var styleInput: String?
    
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
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        updateRestaurantProperty()
        
        SCLAlertView().showSuccess("Restaurant Property Saved", subTitle: "You are great")
    }
    
    func loadForm() {
        form +++ Section("Restaurant Info")
            <<< TextRow(){ row in
                row.title = "Name"
                row.placeholder = selectedRestaurant?.name
                row.tag = "name"
                row.onCellHighlightChanged({ (textCell, textRow) in
                    self.nameInput = row.value
                })
            }
            <<< TextRow(){ row in
                row.title = "Cuisine"
                row.placeholder = selectedRestaurant?.cuisine
                row.onCellHighlightChanged({ (textCell, textRow) in
                    self.cuisineInput = row.value
                })
            }
            <<< TextRow(){ row in
                row.title = "Style"
                row.placeholder = selectedRestaurant?.style
                row.onCellHighlightChanged({ (textCell, textRow) in
                    self.styleInput = row.value
                })
            }
    }
    
    // Update the properties
    func updateRestaurantProperty() {
        if let newName = nameInput {
            do {
                try self.realm.write {
                    self.selectedRestaurant!.name = newName
                }
            } catch {
                print(error)
            }
        }
        
        if let newCuisine = cuisineInput {
            do {
                try self.realm.write {
                    self.selectedRestaurant!.cuisine = newCuisine
                }
            } catch {
                print(error)
            }
        }
        
        if let newStyle = styleInput {
            do {
                try self.realm.write {
                    self.selectedRestaurant!.style = newStyle
                }
            } catch {
                print(error)
            }
        }
    }
    
    // Notify the Restaurant Table View Controller to reload the table
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
    }
    
}
