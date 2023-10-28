//
//  ViewController.swift
//  Todoey
//
//

import UIKit
import RealmSwift
import SwipeCellKit
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    @IBOutlet weak var searchBarView: UISearchBar!
    
    lazy var realm = try! Realm()
    
    var selectedCategory: Category? {
        didSet {
            todoItems = loadItems()
        }
    }
    
    var todoItems : Results<Item>?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Items"
    }
    
    override func viewWillAppear(_ animated: Bool) {
            
            if let colourHex = selectedCategory?.colour {
                title = selectedCategory!.name
                guard let navBar = navigationController?.navigationBar else { fatalError("Navigation controller does not exist.")
                }
                if let navBarColour = UIColor(hexString: colourHex) {
                    //Original setting: navBar.barTintColor = UIColor(hexString: colourHex)
                    //Revised for iOS13 w/ Prefer Large Titles setting:
                    navBar.backgroundColor = navBarColour
                    navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navBarColour, returnFlat: true)]
                    navBar.tintColor = ContrastColorOf(navBarColour, returnFlat: true)
                    searchBarView.barTintColor = navBarColour
                    searchBarView.tintColor = ContrastColorOf(navBarColour, returnFlat: true)
                    var textFieldInsideSearchBar = searchBarView.value(forKey: "searchField") as? UITextField
                    textFieldInsideSearchBar?.textColor = ContrastColorOf(navBarColour, returnFlat: true)
                }
            }
        }
    
    func saveData(_ block: (() throws -> Item)) {
        do {
            try realm.write {
                try realm.add(block())
            }
        } catch {
            print("Error saving db context \(error)")
        }
    }
    
    func updateData(_ block: (() throws -> Item)) {
        do {
            try realm.write {
                try block()
            }
        } catch {
            print("Error updating db context \(error)")
        }
    }
    
    func loadItems() -> Results<Item>? {
        return selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: false)
    }
    
    //MARK: - TableView DataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
            if let colour = UIColor(hexString: selectedCategory!.colour)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)) {
                cell.backgroundColor = colour
                cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
            }
        } else {
            cell.textLabel?.text = "No items added yet!"
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let item = self.todoItems?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(item)
                    tableView.deleteRows(at: [indexPath], with: .fade)                    
                }
            } catch {
                print("\(error) agaya")
            }
        }
    }

    
    //MARK: - TableView Delegate mathods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = todoItems?[indexPath.row] {
            self.updateData {
                item.done = !item.done
                return item
            }
            tableView.cellForRow(at: indexPath)?.accessoryType = item.done ? .checkmark : .none
            tableView.deselectRow(at: indexPath, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Add new items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add new Todoey Item", message: "", preferredStyle: UIAlertController.Style.alert)
        
        var scopedTextField: UITextField? = nil
        
        let addAction = UIAlertAction(title: "Add Item", style: UIAlertAction.Style.default) { (uIAlertAction) in
            if let text = scopedTextField?.text {
                
                
                if let selectedCategory = self.selectedCategory {
                    
                    self.saveData {
                        let item = Item()
                        item.title = text
                        selectedCategory.items.append(item)
                        item.dateCreated = Date()
                        item.done = false
                        return item
                    }
                    
                    self.tableView.reloadData()
                }
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
    

}
//MARK: - SearchBarDelegate
extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: false)
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchBar.text?.count == 0) {
            todoItems = loadItems()
            tableView.reloadData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

