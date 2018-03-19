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
import SVProgressHUD

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
            print("Current Address is \(String(describing: currentLocation))")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategory()
        createFilteredDataToDisplay()
    }
    
    // Loop through every restaurants in each category to filter restaurants to display
    func createFilteredDataToDisplay() {
        if let categories = categories {
            for thisCategory in categories {
                // only populate categories with at least one restaurants
                if (thisCategory.restaurants.count > 0) {
                    let categoryToDisplay = Category()
                    categoryToDisplay.title = thisCategory.title
                    
                    // populate restaurants that are nearby
                    for thisRestaurant in thisCategory.restaurants {
                        // set up HTTP request URL
                        var finalRequestURL: String = ""
                        if var destinationLocation = thisRestaurant.address {
                            destinationLocation = destinationLocation.components(separatedBy: " ").joined(separator: "%20")
                            finalRequestURL = baseURL + "origins=\(currentLocation!)&destinations=\(destinationLocation)&key=\(key)"
                            displayIfNearby(categoryToDisplay: categoryToDisplay , thisRestaurant: thisRestaurant, finalRequestURL: finalRequestURL)
                        }
                    }
                }
            }
        }
    }
    
    // Make an HTTP request to get the travel time to the restaurant and decided whether it is considered nearby
    func displayIfNearby(categoryToDisplay: Category, thisRestaurant: Restaurant, finalRequestURL: String) {
        let nearbyTravelTime = 10
        Alamofire.request(finalRequestURL).responseJSON { (response) in
            if response.result.isSuccess {
                let resultJSON : JSON = JSON(response.result.value!)
                
                // convert the value in seconds to minutes
                let travelTime = resultJSON["rows"][0]["elements"][0]["duration"]["value"].intValue / 60
                print("It will take \(travelTime) minutes to get to \(String(describing: thisRestaurant.name!))")
                
                // add this restaurant for display
                if travelTime <= nearbyTravelTime {
                    let categoryExistsForDisplay = self.categoriesToDisplay.contains { $0.title == categoryToDisplay.title }
                    
                    // set the travel time property of the restaurant for display
                    do {
                        try self.realm.write {
                            thisRestaurant.travelTime = travelTime
                        }
                    } catch {
                        print(error)
                    }
                    
                    // decide if a new category should be added for display
                    if categoryExistsForDisplay {
                        if let first = self.categoriesToDisplay.first(where: { $0.title == categoryToDisplay.title }) {
                            first.restaurants.append(thisRestaurant)
                            self.tableView.reloadData()
                        }
                    }
                    else {
                        categoryToDisplay.restaurants.append(thisRestaurant)
                        self.categoriesToDisplay.append(categoryToDisplay)
                        self.tableView.reloadData()
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
        cell.detailTextLabel?.text = "\(thisRestaurant.travelTime) minutes"
        
        return cell
    }
    
    // ***********************************
    // MARK: - Table View Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // *****************************
    // MARK: - Database Manipulation
    
    func loadCategory() {
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }

}
