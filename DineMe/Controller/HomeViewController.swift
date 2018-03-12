//
//  HomeViewController.swift
//  DineMe
//
//  Created by Kyle Wang on 2018-03-11.
//  Copyright © 2018 Kyle Wang. All rights reserved.
//

import UIKit
import GooglePlacePicker
import RealmSwift

class HomeViewController: UIViewController {
    
    let realm = try! Realm()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }


    @IBAction func pickerPressed(_ sender: Any) {
        let config = GMSPlacePickerConfig(viewport: nil)
        let placePicker = GMSPlacePickerViewController(config: config)
        placePicker.delegate = self
        
        present(placePicker, animated: true, completion: nil)
    }
    
    // Pop up alert to add new restaurant to the archive
    func addRestaurantAlert(withRestaurant newRestaurantName: String) {
        var textInput = UITextField()
        let alert = UIAlertController(title: "New Restaurant", message: "", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Please match category name"
            textInput = textField
        }
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            self.addNewRestaurant(toCategory: textInput.text!, withNewRestaurant: newRestaurantName)
        }
        
        alert.addAction(action)
        present(alert, animated: true) {
            alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        }
    }
    
    // For dismissing UIAlert after add button pressed
    @objc func alertControllerBackgroundTapped()
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    // Write new added restaurant into the database
    func addNewRestaurant(toCategory category: String, withNewRestaurant newRestaurantName: String) {
        
        if let selectedCategory = realm.object(ofType: Category.self, forPrimaryKey: category) {
            do {
                let newRestaurant = Restaurant()
                newRestaurant.name = newRestaurantName
                newRestaurant.dateCreated = Date()
                try realm.write {
                    realm.add(newRestaurant)
                    selectedCategory.restaurants.append(newRestaurant)
                }
            } catch {
                print(error)
            }
        }
    }
}

extension HomeViewController: GMSPlacePickerViewControllerDelegate {
    // To receive the results from the place picker 'self' will need to conform to
    // GMSPlacePickerViewControllerDelegate and implement this code.
    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        
        print("Place name \(place.name)")
        print("Place address \(String(describing: place.formattedAddress))")
        print("Place attributions \(String(describing: place.attributions))")
        addRestaurantAlert(withRestaurant: place.name)
    }
    
    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        
        print("No place selected")
    }

}
