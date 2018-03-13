//
//  NearbyRestaurantTableViewController.swift
//  DineMe
//
//  Created by Kyle Wang on 2018-03-12.
//  Copyright © 2018 Kyle Wang. All rights reserved.
//

import UIKit
import RealmSwift

class NearbyRestaurantTableViewController: UITableViewController {

    let realm = try! Realm()
    
    var categories: Results<Category>?
    var restaurants: Results<Restaurant>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategory()
        loadRestaurant()
        
        if let allCategory = categories {
            for category in allCategory {
                for rest in category.restaurants {
                    print(rest)
                }
            }
        }
    }

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

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "fetchedCell", for: indexPath)
        
        cell.textLabel?.text = categories?[indexPath.section].restaurants[indexPath.row].name
//        cell.textLabel?.text = restaurants?[indexPath.row].name
        
        return cell
    }

    func loadCategory() {
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    func loadRestaurant() {
        restaurants = realm.objects(Restaurant.self)
        tableView.reloadData()
    }

}
