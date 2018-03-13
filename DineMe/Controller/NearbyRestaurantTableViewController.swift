//
//  NearbyRestaurantTableViewController.swift
//  DineMe
//
//  Created by Kyle Wang on 2018-03-12.
//  Copyright © 2018 Kyle Wang. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire
import SwiftyJSON
import GooglePlaces

class NearbyRestaurantTableViewController: UITableViewController {

    let realm = try! Realm()
    var placesClient: GMSPlacesClient!
    
    var categories: Results<Category>?
    var restaurants: Results<Restaurant>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategory()
        loadRestaurant()
        
//        if let allCategory = categories {
//            for category in allCategory {
//                for rest in category.restaurants {
//                    print(rest)
//                }
//            }
//        }
        placesClient = GMSPlacesClient.shared()
        getCurrentLocation()
        placeAutocomplete()
    }

    // *******************************
    // MARK: - Table view data source
    

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return categories?.count ?? 1
    }
    
    // set titles for each section
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var titles = [String]()
        if let allCategory = categories {
            for category in allCategory {
                titles.append(category.title)
            }
            return titles[section]
        }
        return "No Category"
    }

    // number of rows for each section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categories?[section].restaurants.count ?? 0
    }

    // Populate table cell correspond to their section
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "fetchedCell", for: indexPath)
        
        let thisCategory = categories?[indexPath.section]
        let thisRestaurant = thisCategory?.restaurants[indexPath.row]
        cell.textLabel?.text = thisRestaurant?.name
        
        return cell
    }
    
    // *****************************
    // MARK: - Google Places Methods
    
    func getCurrentLocation() {
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
                    addressLabel = place.formattedAddress//?.components(separatedBy: ", ").joined(separator: "\n")
                }
            }
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
        
        
    
    // **************************************
    // MARK: - Alamofire HTTP Request Methods
    
    func distanceMatrixRequest() {
        
    }

    // *****************************
    // MARK: - Database Manipulation
    
    func loadCategory() {
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    func loadRestaurant() {
        restaurants = realm.objects(Restaurant.self)
        tableView.reloadData()
    }

}
