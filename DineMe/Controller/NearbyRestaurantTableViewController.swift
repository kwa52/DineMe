//
//  NearbyRestaurantTableViewController.swift
//  DineMe
//
//  Created by Kyle Wang on 2018-03-12.
//  Copyright © 2018 Kyle Wang. All rights reserved.
//

import UIKit
import RealmSwift
import CoreLocation
import Alamofire
import SwiftyJSON
import GooglePlaces

class NearbyRestaurantTableViewController: UITableViewController {

    let realm = try! Realm()
    let baseURL = "https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&"
    let key = "AIzaSyCRlwZuTqGcHtSj5Bc66v3N7htFFA43a04"
    
    var placesClient: GMSPlacesClient = GMSPlacesClient.shared()
    var categories: Results<Category>?
    var categoriesToDisplay = [Category]()
    var currentLocation: String? {
        didSet {
            currentLocation = currentLocation!.components(separatedBy: " ").joined(separator: "%20")
            print("Current Address is \(currentLocation)")
            
            
        }
    }
    var destinationLocation: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        placesClient = GMSPlacesClient.shared()
//        setCurrentLocation()
        loadCategory()
        createFilteredDataToDisplay()
    }
    
    // Filter Categories to display
    func createFilteredDataToDisplay() {
        if let categories = categories {
            for thisCategory in categories {
                // only populate categories with at least one restaurants
                if (thisCategory.restaurants.count > 0) {
                    let categoryToDisplay = Category()
                    categoryToDisplay.title = thisCategory.title
                    
                    // populate restaurants that are nearby
                    for thisRestaurant in thisCategory.restaurants {
                        var finalRequestURL: String = ""
                        destinationLocation = thisRestaurant.address!
                        destinationLocation = destinationLocation.components(separatedBy: " ").joined(separator: "%20")
                        finalRequestURL = baseURL + "origins=\(currentLocation!)&destinations=\(destinationLocation)&key=\(key)"
                        print("Final Request Address: \(finalRequestURL)")
                        
                        Alamofire.request(finalRequestURL).responseJSON { (response) in
                            if response.result.isSuccess {
                                let resultJSON : JSON = JSON(response.result.value!)
                                print("JSON: \(resultJSON)") // serialized json response
                                
                                // convert the value in seconds to minutes
                                let travelTime = resultJSON["rows"][0]["elements"][0]["duration"]["value"].intValue / 60
                                print("It will take \(travelTime) minutes to get to \(String(describing: thisRestaurant.name!))")
                                
                                // add this restaurant for display
                                if travelTime < 10 {
                                    let categoryExistsForDisplay = self.categoriesToDisplay.contains { $0.title == categoryToDisplay.title }
                                    
                                    if categoryExistsForDisplay {
                                        if let first = self.categoriesToDisplay.first(where: { $0.title == categoryToDisplay.title }) {
                                            first.restaurants.append(thisRestaurant)
                                            self.tableView.reloadData()
                                        }
                                        print("Add new restaurant to existed category \(categoryToDisplay.title) for display")
                                    }
                                    else {
                                        categoryToDisplay.restaurants.append(thisRestaurant)
                                        self.categoriesToDisplay.append(categoryToDisplay)
                                        self.tableView.reloadData()
                                        print("Add new category \(categoryToDisplay.title) to display")
                                    }
                                }
                            }
                        }
                        
                    }
                }
            }
        }
    }
    
    // *******************************
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return categoriesToDisplay.count
    }
    
    // set titles for each section
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var titles = [String]()
        for category in categoriesToDisplay {
            titles.append(category.title)
        }
        return titles[section]
    }

    // number of rows for each section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categoriesToDisplay[section].restaurants.count
    }

    // Populate table cell correspond to their section
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "fetchedCell", for: indexPath)
        
        let thisCategory = categoriesToDisplay[indexPath.section]
        let thisRestaurant = thisCategory.restaurants[indexPath.row]
        
        cell.textLabel?.text = thisRestaurant.name
        
        return cell
    }
    
    // *****************************
    // MARK: - Google Places Methods
    
    func setCurrentLocation() {
        placesClient.currentPlace(callback: { (placeLikelihooodList, error) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            var nameLabel: String?
            var addressLabel: String?
            
            nameLabel = "No current place"
            addressLabel = ""
            
            if let placeLikelihoodList = placeLikelihooodList {
                let place = placeLikelihoodList.likelihoods.first?.place
                if let place = place {
                    nameLabel = place.name
                    self.currentLocation = place.name
                    addressLabel = place.formattedAddress//?.components(separatedBy: ", ").joined(separator: "\n")
                }
            }
            print("Current Location Set: \(self.currentLocation)")
            print("Name Label: \(String(describing: nameLabel))")
            print("Address Label: \(String(describing: addressLabel))")
        })
    }
    
    func placeAutocomplete() {
        
        let filter = GMSAutocompleteFilter()
        filter.type = .establishment
        placesClient.autocompleteQuery("Starbucks", bounds: nil, filter: filter, callback: {
            (results, error) -> Void in
            guard error == nil else {
                print("Autocomplete error \(String(describing: error))")
                return
            }
            if let results = results {
                for result in results {
                    print("Result \(result.attributedFullText) with placeID \(String(describing: result.placeID))")
                }
            }
        })
    }
    
    // MARK: - Utilities
    
    
    

    // *****************************
    // MARK: - Database Manipulation
    
    func loadCategory() {
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }

}
