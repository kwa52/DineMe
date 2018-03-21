//
//  CategoryTableViewController.swift
//  DineMe
//
//  Created by Kyle Wang on 2018-03-01.
//  Copyright © 2018 Kyle Wang. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit


class CategoryTableViewController: UITableViewController {
    
    let realm = try! Realm()
    let realmFolderPath = Realm.Configuration.defaultConfiguration.fileURL!
    
    var categories : Results<Category>?

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        print("FILE PATH --- ", realmFolderPath)
//        // tapRecognizer, placed in viewDidLoad
//        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
//        self.view.addGestureRecognizer(longPressRecognizer)
        
    }

    // Update restaurant count of each category to display at subtitles
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    //
    // MARK: - Table View Data Source Methods
    //

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categories?.count ?? 1
    }

    // ask data source to insert a cell at a row
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as! SwipeTableViewCell
        let itemsCount = categories?[indexPath.row].restaurants.count
        cell.textLabel?.text = categories?[indexPath.row].title ?? "No categories added yet"
        cell.detailTextLabel?.text = "\(itemsCount!) restaurants"
        
        cell.delegate = self
        
        return cell
    }
    
    //
    // MARK: - Table View Delegate Methods
    //

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
        
        performSegue(withIdentifier: "goToRestaurants", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! RestaurantTableViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    
    // Add new category
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var userInput = UITextField()
        let alert = UIAlertController(title: "New Category", message: "", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Enter category name"
            userInput = textField
        }
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            let newCategory = Category()
            newCategory.title = userInput.text!
            
            // write into Realm
            do {
                try self.realm.write {
                    self.realm.add(newCategory)
                }
            } catch {
                print(error)
            }
            self.tableView.reloadData()
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
    
    //Called, when long press occurred
    @objc func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        
        if longPressGestureRecognizer.state == UIGestureRecognizerState.began {
            
            let touchPoint = longPressGestureRecognizer.location(in: self.view)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                
                // your code here, get the row for the indexPath or do whatever you want
                print("long pressed")
            }
        }
    }
    
    //
    //MARK: - Database Methods
    //
    
    func loadData() {
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    // Remove all restaurants when a category is removed
    func removeChild() {
        
    }

    
//    //Override to support conditional editing of the table view.
//    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//         //Return false if you do not want the specified item to be editable.
//        return true
//    }
    

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

extension CategoryTableViewController: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: nil) { action, indexPath in
            // handle action by updating model with deletion
            
            if let categoryToDelete = self.categories?[indexPath.row] {
                do {
                    try self.realm.write {
                        self.realm.delete(categoryToDelete)
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
        
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .border
        return options
    }
    
}
