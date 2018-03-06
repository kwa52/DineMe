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
        
        searchBar.delegate = self
        searchBar.placeholder = "Search restaurants"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        cell.detailTextLabel?.text = formatDate
        
        cell.delegate = self

        return cell
    }
    
    //
    //MARK: - Table View Delegate Methods
    //
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
    }
    
    
    //
    //MARK: - Utilities
    //
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var userInput = UITextField()
        
        let alert = UIAlertController(title: "Add Restaurant", message: "", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Enter new restaurant name"
            userInput = textField
        }
        
        let action = UIAlertAction(title: "Action Title", style: .default) { (action) in
            let newRestaurant = Restaurant()
            newRestaurant.name = userInput.text!
            newRestaurant.dateCreated = Date()
            do {
                try self.realm.write {
                    self.realm.add(newRestaurant)
                    self.selectedCategory?.restaurants.append(newRestaurant)
                }
            } catch {
                print(error)
            }
            
            self.tableView.reloadData()
        }
        
        alert.addAction(action)
        
        self.present(alert, animated: true) {
            alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        }
    }
    
    // For dismissing UIAlert after add button pressed
    @objc func alertControllerBackgroundTapped()
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    //
    //MARK: - Database Methods
    //
    
    func loadData() {
        restaurants = selectedCategory?.restaurants.sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

}


extension RestaurantTableViewController: SwipeTableViewCellDelegate, UISearchBarDelegate {
    
    //
    //MARK: - Swipe Cell Kit Methods
    //
    
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
        restaurants = restaurants?.sorted(byKeyPath: "dateCreated", ascending: true)
        
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
