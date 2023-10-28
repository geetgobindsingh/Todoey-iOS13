//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Geet Gobind Singh on 23/04/23.
//
//

import UIKit
import RealmSwift
import SwipeCellKit
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    lazy var realm = try! Realm()
    
    var categories : Results<Category>?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Todo List"        

        // Do any additional setup after loading the view.
        categories = loadCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else { fatalError("Navigation controller does not exist.")
        }
        navBar.backgroundColor = UIColor(hexString: "#1D9BF6")
    }
    
    func saveData(_ category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving db context \(error)")
        }
    }
    
    func loadCategories() -> Results<Category>? {
        categories = realm.objects(Category.self)
        return categories
    }
    
    
    @IBAction func addCategoryPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add new Todoey Category", message: "", preferredStyle: UIAlertController.Style.alert)
        
        var scopedTextField: UITextField? = nil
        
        let addAction = UIAlertAction(title: "Add Category", style: UIAlertAction.Style.default) { (uIAlertAction) in
            if let text = scopedTextField?.text {
                
                let category = Category()
                category.name = text
                category.colour = UIColor.randomFlat().hexValue()
                
                self.saveData(category)
                
                self.tableView.reloadData()
            }
        }
        
        alert.addAction(addAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { (uIAlertAction) in
            
        }
        
        alert.addAction(cancelAction)
        
        alert.addTextField { (textField: UITextField) in
            scopedTextField = textField
            scopedTextField?.placeholder = "Enter text here..."
        }
        
        present(alert, animated: true)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        let destinationVC = segue.destination
        if (destinationVC is TodoListViewController) {
            let todoListViewController = destinationVC as! TodoListViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                todoListViewController.selectedCategory = categories?[indexPath.row]
            }
        }
    }
    
    
    //MARK: - TableView DataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        if let category = categories?[indexPath.row] {
            cell.textLabel?.text = category.name
            guard let categoryColour = UIColor(hexString: category.colour) else {fatalError()}
            cell.backgroundColor = categoryColour
            cell.textLabel?.textColor = ContrastColorOf(categoryColour, returnFlat: true)
        } else {
            cell.textLabel?.text = "No Categories Added Yet"
        }
       
        return cell
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let category = self.categories?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(category)
                    tableView.deleteRows(at: [indexPath], with: .fade)                    
                }
            } catch {
                print("\(error) agaya")
            }
        }
    }
       
    
    //MARK: - TableView Delegate mathods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "GoToItems", sender: self)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
