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
    var addressInput: String?
    var formattedDate: String?
    
    var selectedRestaurant : Restaurant? {
        didSet {
            formatDate()
            loadForm()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RestaurantFormViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    // Notify the Restaurant Table View Controller to reload the table
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
    }
    
    // Tap outside to disable keyboard
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // Save updated property
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        updateRestaurantProperty()
        
        SCLAlertView().showSuccess("New Property Saved", subTitle: "")
        dismissKeyboard()
    }
    
    // Load Form
    func loadForm() {
        form +++ Section("Restaurant Info")
            +++ Section(footer: "Date Created: \(formattedDate ?? "No Date")")
            <<< TextRow(){ row in
                row.title = "Name"
                row.placeholder = selectedRestaurant?.name
                row.onChange({ (textRow) in
                    self.nameInput = row.value
                })
            }
            <<< TextRow(){ row in
                row.title = "Cuisine"
                row.placeholder = selectedRestaurant?.cuisine
                row.onChange({ (textRow) in
                    self.cuisineInput = row.value
                })
            }
            <<< TextRow(){ row in
                row.title = "Style"
                row.placeholder = selectedRestaurant?.style
                row.onChange({ (textRow) in
                    self.styleInput = row.value
                })
            }
            <<< TextRow(){ row in
                row.title = "Address"
                row.placeholder = selectedRestaurant?.address
                row.onChange({ (textRow) in
                    self.addressInput = row.value
                })
        }
    }
    
    // Update the properties
    func updateRestaurantProperty() {
        if let newName = nameInput {
            updateName(with: newName)
        }
        
        if let newCuisine = cuisineInput {
            updateCuisine(with: newCuisine)
        }
        
        if let newStyle = styleInput {
            updateStyle(with: newStyle)
        }
        if let newAddress = addressInput {
            updateAddress(with: newAddress)
        }
    }
    
    // Format selected restaurant created date to be more readable
    func formatDate() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MMM-yyyy"
        formattedDate = formatter.string(from: (selectedRestaurant?.dateCreated)!)
    }
    
    
    //************************
    //
    //MARK: - Helper Functions
    //
    //************************
    
    
    
    // Helper Funcitons
    func updateName(with newName: String) {
        do {
            try self.realm.write {
                self.selectedRestaurant!.name = newName
            }
        } catch {
            print(error)
        }
    }
    
    func updateCuisine(with newCuisine: String) {
        do {
            try self.realm.write {
                self.selectedRestaurant!.cuisine = newCuisine
            }
        } catch {
            print(error)
        }
    }
    
    func updateStyle(with newStyle: String) {
        do {
            try self.realm.write {
                self.selectedRestaurant!.style = newStyle
            }
        } catch {
            print(error)
        }
    }
    func updateAddress(with newAddress: String) {
        do {
            try self.realm.write {
                self.selectedRestaurant!.address = newAddress
            }
        } catch {
            print(error)
        }
    }
}
