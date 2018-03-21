//
//  RestaurantTableViewController.swift
//  DineMe
//
//  Created by Kyle Wang on 2018-03-05.
//  Copyright © 2018 Kyle Wang. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit
import SCLAlertView

class RestaurantTableViewController: UITableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    let realm = try! Realm()
    
    var restaurants : Results<Restaurant>?
    var selectedCategory : Category? {
        didSet {
            loadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // For refreshing the table view when restaurant attributes has been modified in the edit form
        NotificationCenter.default.addObserver(self, selector: #selector(loadData), name: NSNotification.Name(rawValue: "load"), object: nil)
        
        searchBar.delegate = self
        searchBar.placeholder = "Search restaurants..."
    }

    //
    // MARK: - Table view data source
    //

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return restaurants?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let formatter = DateFormatter()
        let formatDate : String?
        let cell = tableView.dequeueReusableCell(withIdentifier: "restaurantCell", for: indexPath) as! SwipeTableViewCell
        
        formatter.dateFormat = "dd-MMM-yyyy"
        formatDate = formatter.string(from: (restaurants?[indexPath.row].dateCreated)!)
        
        cell.textLabel?.text = restaurants?[indexPath.row].name
        cell.detailTextLabel?.text = restaurants?[indexPath.row].address ?? "No address exists"
        
        cell.delegate = self

        return cell
    }
    
    //***********************************
    //
    //MARK: - Table View Delegate Methods
    //
    //***********************************
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
        
        performSegue(withIdentifier: "goToEditForm", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! RestaurantFormViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedRestaurant = restaurants?[indexPath.row]
        }
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
    }
    
    //*****************
    //
    //MARK: - Utilities
    //
    //*****************
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
    
        let alert = SCLAlertView()
        let nameTextField = alert.addTextField("Restaurant Name")
        let cuisineTextField = alert.addTextField("Enter type of cuisine")
        let styleTextField = alert.addTextField("Enter style")
        let addressTextField = alert.addTextField("Enter address")
        
        alert.addButton("Add") {
            if !(nameTextField.text?.isEmpty)! {
                let newRestaurant = Restaurant(
                    name: nameTextField.text!,
                    cuisine: cuisineTextField.text!,
                    style: styleTextField.text!,
                    address: addressTextField.text!
                )
                do {
                    try self.realm.write {
                        self.realm.add(newRestaurant)
                        self.selectedCategory?.restaurants.append(newRestaurant)
                    }
                } catch {
                    print(error)
                }
            }
            self.tableView.reloadData()
        }
        alert.showEdit("New Restaurant", subTitle: "empty address will affect results")
    }
    
    //************************
    //
    //MARK: - Database Methods
    //
    //************************
    
    @objc func loadData() {
        restaurants = selectedCategory?.restaurants.sorted(byKeyPath: "dateCreated", ascending: false)
        tableView.reloadData()
    }
}




//                **********************      Extentions      ****************************


extension RestaurantTableViewController: SwipeTableViewCellDelegate, UISearchBarDelegate {
    
    //******************************
    //
    //MARK: - Swipe Cell Kit Methods
    //
    //******************************
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: nil) { action, indexPath in
            // handle action by updating model with deletion
            
            if let restaurantToDelete = self.restaurants?[indexPath.row] {
                do {
                    try self.realm.write {
                        self.realm.delete(restaurantToDelete)
                    }
                } catch {
                    print(error)
                }
            }
        }
        
        let moreAction = SwipeAction(style: .default, title: nil) { action, indexPath in
            self.tableView.isEditing = true
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(named: "delete-icon")
        moreAction.image = UIImage(named: "more-icon")
        moreAction.hidesWhenSelected = true
        
        return [deleteAction, moreAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .border
        return options
    }
    
    //
    //MARK: - Search Bar Methods
    //
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let predicate = NSPredicate(format: "name CONTAINS %@", argumentArray: [searchBar.text!])
        
        restaurants = restaurants?.filter(predicate)
        restaurants = restaurants?.sorted(byKeyPath: "dateCreated", ascending: false)
        
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadData()
            
            DispatchQueue.main.async {
                // dismiss the keyboard and cursor on the search bar
                searchBar.resignFirstResponder()
            }
        }
    }
}
