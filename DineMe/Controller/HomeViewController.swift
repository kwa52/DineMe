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
import SVProgressHUD
import SwiftIcons

class HomeViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let geocodeKey = "AIzaSyCt05eIT5U9_VWFQkwYTFmTme5z8IJ5VEg"
    let baseURL = "https://maps.googleapis.com/maps/api/geocode/json?latlng="
    let realm = try! Realm()
    let locationManager = CLLocationManager()

    var currentAddress: String?
    var categories: Results<Category>?
    // the chosen category for picker view
    var pickerValue: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Called everytime when this view is about to appear (add to the controller stack or dismiss from other view)
    override func viewWillAppear(_ animated: Bool) {
        loadCategory()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
    }
    
    // Action for fetching nearby restaurants
    @IBAction func lookUpButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "goToNearby", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToNearby" {
            let destinationVC = segue.destination as! NearbyRestaurantTableViewController
            destinationVC.currentLocation = currentAddress
        }
    }
    
    // Go to Place Picker
    @IBAction func pickerPressed(_ sender: Any) {
        let config = GMSPlacePickerConfig(viewport: nil)
        let placePicker = GMSPlacePickerViewController(config: config)
        placePicker.delegate = self
        
        present(placePicker, animated: true, completion: nil)
    }
    
    // ***************************************
    // MARK: - Picker View Data Source Methods
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories?.count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories?[row].title ?? "Add a category at Your Restaurant"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerValue = categories?[row].title
    }
    
    // Pop up alert for adding restaurant to a selected category
    func restaurantPickerView(withRestaurant newRestaurant: GMSPlace) {
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: 250,height: 250)
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: 250, height: 250))
        pickerView.selectRow(1, inComponent: 1, animated: true)
        pickerView.delegate = self
        pickerView.dataSource = self
        vc.view.addSubview(pickerView)
        let editRadiusAlert = UIAlertController(title: "Choose Category", message: "", preferredStyle: .alert)
        editRadiusAlert.setValue(vc, forKey: "contentViewController")
        
        editRadiusAlert.addAction(UIAlertAction(title: "Add", style: .default) { (action) in
            // only proceed if category list is not empty
            if self.categories?.count != 0{
                // check if the picker value is nil since the picker default value is nil if not yet scrolled
                if let pickerValue = self.pickerValue {
                    self.addNewRestaurant(toCategory: pickerValue, withNewRestaurant: newRestaurant)
                }
                // if user tapped "Add" without scrolling then set the category to the first of the list
                else {
                    self.pickerValue = self.categories![0].title
                    self.addNewRestaurant(toCategory: self.pickerValue, withNewRestaurant: newRestaurant)
                }
            }
        })
        editRadiusAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(editRadiusAlert, animated: true)
    }
    
    // Pop up alert to add new restaurant to the archive after selected from Place Picker
    func addRestaurantAlert(withRestaurant newRestaurant: GMSPlace) {
        let alert = UIAlertController(title: "New Restaurant", message: "select a category and press Add", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            self.addNewRestaurant(toCategory: self.pickerValue!, withNewRestaurant: newRestaurant)
        }
        alert.addAction(action)
        present(alert, animated: true) {
            alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        }
    }
    
    // Alert when user wants to add a new restaurant without an existing category created
    func emptyCategoryAlert() {
        let alert = UIAlertController(title: "Empty Category", message: "please create a new category", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    // For dismissing UIAlert after add button pressed
    @objc func alertControllerBackgroundTapped()
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    // Write newly added restaurant from Place Picker into the database
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
    
    // Load Categories
    func loadCategory() {
        categories = realm.objects(Category.self)
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
        
        // show different alert view based on if category list is empty
        if ((categories?.count)! > 0) {
            restaurantPickerView(withRestaurant: place)
        }
        else {
            emptyCategoryAlert()
        }
    }
    
    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
    }
    
    // ********************************
    
    // MARK: - Locatoin Manager Methods
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
//        print("Current Location: \(location)")
        
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
