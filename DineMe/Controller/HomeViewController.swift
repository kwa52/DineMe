//
//  HomeViewController.swift
//  DineMe
//
//  Created by Kyle Wang on 2018-03-11.
//  Copyright © 2018 Kyle Wang. All rights reserved.
//

import UIKit
import CoreLocation
import GooglePlacePicker
import RealmSwift
import Alamofire
import SwiftyJSON

class HomeViewController: UIViewController {
    
    let geocodeKey = "AIzaSyCt05eIT5U9_VWFQkwYTFmTme5z8IJ5VEg"
    let baseURL = "https://maps.googleapis.com/maps/api/geocode/json?latlng="
    let realm = try! Realm()
    let locationManager = CLLocationManager()

    var currentAddress: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func lookUpButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "goToNearby", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToNearby" {
            let destinationVC = segue.destination as! NearbyRestaurantTableViewController
            destinationVC.currentLocation = currentAddress
        }
    }
    
    @IBAction func pickerPressed(_ sender: Any) {
        let config = GMSPlacePickerConfig(viewport: nil)
        let placePicker = GMSPlacePickerViewController(config: config)
        placePicker.delegate = self
        
        present(placePicker, animated: true, completion: nil)
    }
    
    // Pop up alert to add new restaurant to the archive after selected from Place Picker
    func addRestaurantAlert(withRestaurant newRestaurant: GMSPlace) {
        var textInput = UITextField()
        let alert = UIAlertController(title: "New Restaurant", message: "", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Please match category name"
            textInput = textField
        }
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            self.addNewRestaurant(toCategory: textInput.text!, withNewRestaurant: newRestaurant)
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
    func addNewRestaurant(toCategory category: String, withNewRestaurant pickedRestaurant: GMSPlace) {
        
        // get the category object which name matches what user typed in the UIAlert text field
        if let selectedCategory = realm.object(ofType: Category.self, forPrimaryKey: category) {
            do {
                let newRestaurant = Restaurant()
                newRestaurant.name = pickedRestaurant.name
                newRestaurant.address = pickedRestaurant.formattedAddress
                newRestaurant.placeID = pickedRestaurant.placeID
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

extension HomeViewController: GMSPlacePickerViewControllerDelegate, CLLocationManagerDelegate {
    
    // ********************************
    // MARK: - Place Picker Methods
    
    // To receive the results from the place picker 'self' will need to conform to
    // GMSPlacePickerViewControllerDelegate and implement this code.
    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        
        print("Place name \(place.name)")
        print("Place address \(String(describing: place.formattedAddress))")
        print("Place attributions \(String(describing: place.attributions))")
        addRestaurantAlert(withRestaurant: place)
    }
    
    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        
        print("No place selected")
    }
    
    // ********************************
    
    // MARK: - Locatoin Manager Methods
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        print("Current Location: \(location)")
        
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
        }
        
        let latitude = String(location.coordinate.latitude)
        let longitude = String(location.coordinate.longitude)
        var finalURL = ""
        
        finalURL = baseURL + "\(latitude),\(longitude)&key=\(geocodeKey)"
        print("Final URL: \(finalURL)")
        
        // Geocode coordinates to address
        Alamofire.request(finalURL).responseJSON { (response) in
            if response.result.isSuccess {
                let resultJSON : JSON = JSON(response.result.value!)
                print("JSON: \(resultJSON)")
                
                let returnAddress = resultJSON["results"][0]["formatted_address"]
                print("Returned Address: \(returnAddress)")
                self.currentAddress = returnAddress.stringValue
            }
        }
        
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }

}
